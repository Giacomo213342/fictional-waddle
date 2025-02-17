import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../polycule_http_client/polycule_http_client.dart';
import '../settings_interface.dart';
import 'client_util.dart';
import 'push_manager.dart';

@pragma('vm:entry-point')
Future<void> pushEntrypoint() async {
  await UnifiedPush.initialize(
    onMessage: handleBackgroundNotification,
  );
}

Future<void> handleBackgroundNotification(
  Uint8List message,
  String instance,
) async {
  // first load our network settings from storage
  final settings = await const SettingsInterface().getNetwork();
  await PolyculeHttpClientManager.init(ValueNotifier(settings));
  final httpCallback =
      await PolyculeHttpClientManager.httpClientCallbackStream.first;

  final client = ClientUtil.clientConstructor(instance, httpCallback.call());

  final locale = WidgetsBinding.instance.platformDispatcher
          .computePlatformResolvedLocale(AppLocalizations.supportedLocales) ??
      const Locale('en');
  final l10n = await AppLocalizations.delegate.load(locale);
  handlePushNotification(client: client, l10n: l10n, message: message);
}

Future<void> handlePushNotification({
  required Client client,
  required AppLocalizations l10n,
  required Uint8List message,
}) async {
  final notification = decodeMessage(message);

  WidgetsFlutterBinding.ensureInitialized();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  await PushManager.initializeNotificationPlugin(l10n);

  // this code is mostly based on FluffyChat's implementation - huge credits
  final event = await client.getEventByPushNotification(
    notification,
    storeInDatabase: false,
  );

  if (event == null) {
    Logs().v('Notification is a clearing indicator.');
    if (notification.counts?.unread == null ||
        notification.counts?.unread == 0) {
      await notificationsPlugin.cancelAll();
    } else {
      await client.roomsLoading;
      await client.oneShotSync();
      final activeNotifications =
          await notificationsPlugin.getActiveNotifications();
      for (final activeNotification in activeNotifications) {
        final room = client.rooms
            .where(
              (room) => room.id.hashCode == activeNotification.id,
            )
            .singleOrNull;
        if (room == null || !room.isUnreadOrInvited) {
          notificationsPlugin.cancel(activeNotification.id!);
        }
      }
    }
    return;
  }

  final id = notification.roomId.hashCode;

  final body = event.type == EventTypes.Encrypted
      ? l10n.newNotification
      : await event.calcLocalizedBody(
          l10n.matrix,
          plaintextBody: true,
          withSenderNamePrefix: false,
          hideReply: true,
          hideEdit: true,
          removeMarkdown: true,
        );
  final messagingStyleInformation = !kIsWeb && Platform.isAndroid
      ? await AndroidFlutterLocalNotificationsPlugin()
          .getActiveNotificationMessagingStyle(id)
      : null;

  final sender = event.senderFromMemoryOrFallback;

  final person = Person(
    bot: event.messageType == MessageTypes.Notice,
    important: event.room.isFavourite,
    key: event.senderId,
    icon: await sender.avatarUrl?.downloadAndroidIcon(client),
    name: sender.calcDisplayname(
      i18n: l10n.matrix,
    ),
  );

  final newMessage = Message(
    body,
    event.originServerTs,
    person,
  );

  messagingStyleInformation?.messages?.add(newMessage);

  final roomName = event.room.getLocalizedDisplayname(
    l10n.matrix,
  );

  final notificationGroupId =
      event.room.isDirectChat ? 'directChats' : 'groupChats';
  final groupName = event.room.isDirectChat ? l10n.directChats : l10n.groups;

  final messageRooms = AndroidNotificationChannelGroup(
    notificationGroupId,
    groupName,
  );
  final roomsChannel = AndroidNotificationChannel(
    event.room.id,
    roomName,
    groupId: notificationGroupId,
  );

  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannelGroup(messageRooms);
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(roomsChannel);

  final androidPlatformChannelSpecifics = AndroidNotificationDetails(
    'polycule.notifications',
    l10n.pushChannelName,
    number: notification.counts?.unread,
    category: AndroidNotificationCategory.message,
    icon: '@drawable/ic_launcher_foreground',
    shortcutId: event.room.id,
    styleInformation: messagingStyleInformation ??
        MessagingStyleInformation(
          person,
          htmlFormatContent: true,
          conversationTitle: roomName,
          groupConversation: !event.room.isDirectChat,
          messages: [newMessage],
        ),
    ticker: event.calcLocalizedBodyFallback(
      l10n.matrix,
      plaintextBody: true,
      withSenderNamePrefix: true,
      hideReply: true,
      hideEdit: true,
      removeMarkdown: true,
    ),
    importance: Importance.high,
    priority: Priority.max,
    groupKey: notificationGroupId,
  );
  const iOSPlatformChannelSpecifics = DarwinNotificationDetails();
  final platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  final title = event.room.getLocalizedDisplayname(l10n.matrix);

  await notificationsPlugin.show(
    id,
    title,
    body,
    platformChannelSpecifics,
    payload: event.roomId,
  );
}

PushNotification decodeMessage(Uint8List message) {
  final content = utf8.decode(message);
  final json = jsonDecode(content);
  final data = Map<String, dynamic>.from(
    json['notification'],
  );
  return PushNotification.fromJson(data);
}

extension GetAndroidIcon on Uri {
  Future<ByteArrayAndroidIcon?> downloadAndroidIcon(Client client) async {
    final bytes = await client.database?.getFile(this);
    if (bytes == null) {
      return null;
    }
    return ByteArrayAndroidIcon(bytes);
  }
}
