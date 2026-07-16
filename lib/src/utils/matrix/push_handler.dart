import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../widgets/matrix/client_manager/client_store.dart';
import '../polycule_http_client/polycule_http_client.dart';
import '../settings_interface.dart';
import '../unified_push/unified_push_storage_polycule.dart';
import 'active_room_tracker.dart';
import 'client_util.dart';
import 'poll_event.dart';
import 'push_manager.dart';

@pragma('vm:entry-point')
Future<void> pushEntrypoint() async {
  await UnifiedPush.initialize(
    onMessage: handleBackgroundNotification,
    linuxOptions: LinuxOptions(
      dbusName: 'business.braid.polycule',
      storage: UnifiedPushStoragePolycule(),
      background: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<void> handleBackgroundNotification(
  PushMessage message,
  String instance,
) async {
  WidgetsFlutterBinding.ensureInitialized();
  // first load our network settings from storage
  final settings = await const SettingsInterface().getNetwork();
  await PolyculeHttpClientManager.init(ValueNotifier(settings));
  final httpCallback =
      await PolyculeHttpClientManager.httpClientCallbackStream.first;

  final client = await ClientUtil.clientConstructor(
    instance,
    httpCallback.call(),
  );

  final locale =
      WidgetsBinding.instance.platformDispatcher.computePlatformResolvedLocale(
            AppLocalizations.supportedLocales,
          ) ??
          const Locale('en');
  final l10n = await AppLocalizations.delegate.load(locale);
  try {
    await handlePushNotification(
      client: client,
      l10n: l10n,
      message: message.content,
    );
  } finally {
    await client.dispose();
  }
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
  Event? event;
  var eventLookupFailed = false;
  try {
    // This SDK helper deliberately works with an uninitialized client. Calling
    // client.init() here starts a sync and can starve the short-lived Android
    // background service after the app has been removed from recents.
    event = await client.getEventByPushNotification(
      notification,
      storeInDatabase: false,
      timeoutForServerRequests: const Duration(seconds: 6),
    );
  } catch (error, stackTrace) {
    eventLookupFailed = true;
    Logs().w(
      'Unable to resolve push event; showing fallback.',
      error,
      stackTrace,
    );
  }

  if (event == null) {
    if (eventLookupFailed && notification.roomId != null) {
      await _showFallbackNotification(
        notificationsPlugin: notificationsPlugin,
        client: client,
        l10n: l10n,
        notification: notification,
      );
      return;
    }
    Logs().v('Notification is a clearing indicator.');
    if (notification.counts?.unread == null ||
        notification.counts?.unread == 0) {
      await notificationsPlugin.cancelAll();
    }
    return;
  }

  final roomId = event.roomId;
  if (roomId != null && ActiveRoomTracker.isVisible(roomId)) {
    await notificationsPlugin.cancel(roomId.hashCode);
    return;
  }

  if (event.room.pushRuleState == PushRuleState.dontNotify) {
    await notificationsPlugin.cancel(event.room.id.hashCode);
    return;
  }

  final id = event.room.id.hashCode;

  final body = event.isPollStart
      ? 'Poll: ${event.pollQuestion ?? l10n.newNotification}'
      : event.type == EventTypes.Encrypted
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
    name: sender.calcDisplayname(i18n: l10n.matrix),
  );

  final newMessage = Message(body, event.originServerTs, person);

  messagingStyleInformation?.messages?.add(newMessage);

  final roomName = event.room.getLocalizedDisplayname(l10n.matrix);

  final notificationGroupId =
      event.room.isDirectChat ? 'directChats' : 'groupChats';
  final groupName = event.room.isDirectChat ? l10n.directChats : l10n.groups;

  if (Platform.isAndroid) {
    try {
      const channel = MethodChannel('polycule.shortcuts');
      await channel.invokeMethod('publishConversationShortcut', {
        'id': event.room.id,
        'name': roomName,
      });
    } catch (e) {
      Logs().w('Failed to publish conversation shortcut', e);
    }
  }

  final messageRooms = AndroidNotificationChannelGroup(
    notificationGroupId,
    groupName,
  );
  final roomsChannel = AndroidNotificationChannel(
    event.room.id,
    roomName,
    groupId: notificationGroupId,
    importance: Importance.high,
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
    event.room.id,
    roomName,
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
    payload: jsonEncode({
      'client': client.clientName.clientIdentifier,
      'room': event.roomId,
    }),
  );
}

Future<void> _showFallbackNotification({
  required FlutterLocalNotificationsPlugin notificationsPlugin,
  required Client client,
  required AppLocalizations l10n,
  required PushNotification notification,
}) async {
  final roomId = notification.roomId!;
  final roomName = notification.roomName ?? l10n.appName;
  final channel = AndroidNotificationChannel(
    roomId,
    roomName,
    importance: Importance.high,
  );
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  await notificationsPlugin.show(
    roomId.hashCode,
    roomName,
    l10n.newNotification,
    NotificationDetails(
      android: AndroidNotificationDetails(
        roomId,
        roomName,
        icon: '@drawable/ic_launcher_foreground',
        category: AndroidNotificationCategory.message,
        importance: Importance.high,
        priority: Priority.max,
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    payload: jsonEncode({
      'client': client.clientName.clientIdentifier,
      'room': roomId,
    }),
  );
}

PushNotification decodeMessage(Uint8List message) {
  final content = utf8.decode(message);
  final json = jsonDecode(content);
  final data = Map<String, dynamic>.from(json['notification']);
  return PushNotification.fromJson(data);
}

extension GetAndroidIcon on Uri {
  Future<ByteArrayAndroidIcon?> downloadAndroidIcon(Client client) async {
    final bytes = await client.database.getFile(this);
    if (bytes == null) {
      return null;
    }
    return ByteArrayAndroidIcon(bytes);
  }
}
