import 'dart:async';
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
import 'cached_push_rules.dart';
import 'client_util.dart';
import 'push_manager.dart';
import 'poll_event.dart';

final Map<String, Future<void>> _backgroundNotificationQueues = {};
const _headlessStorageTimeout = Duration(seconds: 5);
const _headlessRequestTimeout = Duration(seconds: 8);

@pragma('vm:entry-point')
Future<void> pushEntrypoint() async {
  await UnifiedPush.initialize(
    onMessage: _queueBackgroundNotification,
    linuxOptions: LinuxOptions(
      dbusName: 'business.braid.polycule',
      storage: UnifiedPushStoragePolycule(),
      background: true,
    ),
  );
}

void _queueBackgroundNotification(PushMessage message, String instance) {
  final previous = _backgroundNotificationQueues[instance] ?? Future.value();
  late final Future<void> tracked;
  tracked = previous
      .then((_) => handleBackgroundNotification(message, instance))
      .catchError((Object error, StackTrace stackTrace) {
    Logs().e('Queued background notification failed.', error, stackTrace);
  }).whenComplete(() {
    if (identical(_backgroundNotificationQueues[instance], tracked)) {
      _backgroundNotificationQueues.remove(instance);
    }
  });
  _backgroundNotificationQueues[instance] = tracked;
  unawaited(tracked);
}

@pragma('vm:entry-point')
Future<void> handleBackgroundNotification(
  PushMessage message,
  String instance,
) async {
  final stopwatch = Stopwatch()..start();
  WidgetsFlutterBinding.ensureInitialized();
  final locale =
      WidgetsBinding.instance.platformDispatcher.computePlatformResolvedLocale(
            AppLocalizations.supportedLocales,
          ) ??
          const Locale('en');
  final l10n = await AppLocalizations.delegate.load(locale);
  Client? client;
  Set<String>? mutedRoomIds;
  Logs().i('Background notification received for $instance.');
  final placeholderShown = await _showBackgroundFallbackNotification(
    instance: instance,
    client: null,
    l10n: l10n,
    message: message.content,
    mutedRoomIds: null,
  );
  if (placeholderShown) {
    Logs().i(
      'Background placeholder shown after ${stopwatch.elapsedMilliseconds}ms.',
    );
  }
  try {
    Logs().d('Loading headless network settings.');
    final settings = await const SettingsInterface()
        .getNetwork()
        .timeout(_headlessStorageTimeout);
    await PolyculeHttpClientManager.init(
      ValueNotifier(settings),
    ).timeout(_headlessStorageTimeout);
    final httpCallback = await PolyculeHttpClientManager.httpClientCallback
        .timeout(_headlessStorageTimeout);

    Logs().d('Opening headless Matrix client.');
    client = await ClientUtil.clientConstructor(
      instance,
      httpCallback.call(),
      requestTimeout: _headlessRequestTimeout,
    );
    mutedRoomIds = await _prepareHeadlessPushClient(client);
    Logs().d('Looking up Matrix event for background notification.');
    await handlePushNotification(
      client: client,
      l10n: l10n,
      message: message.content,
      mutedRoomIds: mutedRoomIds,
      performClearingSync: false,
      eventLookupTimeout: const Duration(seconds: 6),
      publishShortcut: false,
    );
  } catch (error, stackTrace) {
    Logs().e('Background notification failed.', error, stackTrace);
    if (!placeholderShown) {
      await _showBackgroundFallbackNotification(
        instance: instance,
        client: client,
        l10n: l10n,
        message: message.content,
        mutedRoomIds: mutedRoomIds,
      );
    }
  } finally {
    if (client != null) {
      try {
        await client.dispose().timeout(_headlessStorageTimeout);
      } catch (error, stackTrace) {
        Logs()
            .w('Failed to dispose headless Matrix client.', error, stackTrace);
      }
    }
    Logs().i(
      'Background notification finished in ${stopwatch.elapsedMilliseconds}ms.',
    );
  }
}

Future<bool> _showBackgroundFallbackNotification({
  required String instance,
  required Client? client,
  required AppLocalizations l10n,
  required Uint8List message,
  required Set<String>? mutedRoomIds,
}) async {
  try {
    final notification = decodeMessage(message);
    final roomId = notification.roomId;
    if (roomId == null || mutedRoomIds?.contains(roomId) == true) return false;
    if (mutedRoomIds == null) {
      Logs().w(
        'Showing fallback without cached mute rules for $instance.',
      );
    }

    await PushManager.initializeNotificationPlugin(
      l10n,
      processLaunchDetails: false,
    ).timeout(_headlessStorageTimeout);
    final plugin = FlutterLocalNotificationsPlugin();
    final roomName = notification.roomName ?? l10n.appName;
    if (!kIsWeb && Platform.isAndroid) {
      await plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
            AndroidNotificationChannel(
              roomId,
              roomName,
              importance: Importance.high,
            ),
          );
    }
    final clientIdentifier = client?.clientName.clientIdentifier ??
        int.tryParse(RegExp(r'(\d+)$').firstMatch(instance)?.group(1) ?? '');
    await plugin.show(
      roomId.hashCode,
      roomName,
      l10n.newNotification,
      NotificationDetails(
        android: AndroidNotificationDetails(
          roomId,
          roomName,
          onlyAlertOnce: true,
          importance: Importance.high,
          priority: Priority.max,
          category: AndroidNotificationCategory.message,
          icon: '@drawable/ic_launcher_foreground',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: clientIdentifier == null
          ? null
          : jsonEncode({'client': clientIdentifier, 'room': roomId}),
    );
    return true;
  } catch (error, stackTrace) {
    Logs().e('Fallback background notification failed.', error, stackTrace);
    return false;
  }
}

Future<Set<String>> _prepareHeadlessPushClient(Client client) async {
  final account = await client.database.getClient(client.clientName);
  final homeserver = account?['homeserver_url'];
  final accessToken = account?['token'];
  if (homeserver is! String || accessToken is! String) {
    throw StateError('No stored Matrix session for ${client.clientName}.');
  }

  client
    ..homeserver = Uri.parse(homeserver)
    ..accessToken = accessToken
    ..backgroundSync = false;

  final accountData = await client.database.getAccountData();
  return mutedRoomIdsFromPushRules(
    accountData[EventTypes.PushRules]?.content,
  );
}

Future<void> handlePushNotification({
  required Client client,
  required AppLocalizations l10n,
  required Uint8List message,
  Set<String> mutedRoomIds = const {},
  bool performClearingSync = true,
  Duration eventLookupTimeout = const Duration(seconds: 8),
  bool publishShortcut = true,
}) async {
  final notification = decodeMessage(message);

  WidgetsFlutterBinding.ensureInitialized();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  await PushManager.initializeNotificationPlugin(l10n);

  // this code is mostly based on FluffyChat's implementation - huge credits
  final event = await client.getEventByPushNotification(
    notification,
    storeInDatabase: false,
    timeoutForServerRequests: eventLookupTimeout,
  );

  if (event == null) {
    Logs().v('Notification is a clearing indicator.');
    if (notification.counts?.unread == null ||
        notification.counts?.unread == 0) {
      await notificationsPlugin.cancelAll();
    } else if (performClearingSync) {
      await client.roomsLoading;
      await client.oneShotSync();
      final activeNotifications =
          await notificationsPlugin.getActiveNotifications();
      for (final activeNotification in activeNotifications) {
        final room = client.rooms
            .where((room) => room.id.hashCode == activeNotification.id)
            .singleOrNull;
        if (room == null || !room.isUnreadOrInvited) {
          await notificationsPlugin.cancel(activeNotification.id!);
        }
      }
    }
    return;
  }

  final roomId = event.roomId;
  if (roomId != null && ActiveRoomTracker.isVisible(roomId)) {
    await notificationsPlugin.cancel(roomId.hashCode);
    return;
  }

  if (mutedRoomIds.contains(event.room.id) ||
      event.room.pushRuleState == PushRuleState.dontNotify) {
    await notificationsPlugin.cancel(event.room.id.hashCode);
    return;
  }

  final id = event.room.id.hashCode;

  final body = event.type == EventTypes.Encrypted
      ? l10n.newNotification
      : event.isPollStart
          ? 'Poll: ${event.pollQuestion ?? 'Poll'}'
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

  if (Platform.isAndroid && publishShortcut) {
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
    onlyAlertOnce: true,
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
    ticker: event.isPollStart
        ? 'Poll: ${event.pollQuestion ?? 'Poll'}'
        : event.calcLocalizedBodyFallback(
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
