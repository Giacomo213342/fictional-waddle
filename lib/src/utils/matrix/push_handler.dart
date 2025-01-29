import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';

Future<void> handlePushNotification({
  required Client client,
  required PushNotification notification,
  required AppLocalizations l10n,
}) async {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
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

  final newMessage = Message(
    body,
    event.originServerTs,
    Person(
      bot: event.messageType == MessageTypes.Notice,
      key: event.senderId,
      name: event.senderFromMemoryOrFallback.calcDisplayname(
        i18n: l10n.matrix,
      ),
    ),
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
          Person(
            name: event.senderFromMemoryOrFallback.calcDisplayname(
              i18n: l10n.matrix,
            ),
            key: event.roomId,
            important: event.room.isFavourite,
          ),
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
