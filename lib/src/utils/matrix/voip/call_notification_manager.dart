import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';

import 'call_log_journal.dart';

enum CallNotificationAction { show, answer, decline, hangup }

class CallNotificationIntent {
  const CallNotificationIntent({
    required this.clientIdentifier,
    required this.roomId,
    required this.callId,
    required this.action,
  });

  final int clientIdentifier;
  final String roomId;
  final String callId;
  final CallNotificationAction action;
}

abstract final class CallNotificationManager {
  static const answerActionId = 'polycule.call.answer';
  static const declineActionId = 'polycule.call.decline';
  static const hangupActionId = 'polycule.call.hangup';
  static const _incomingChannelId = 'polycule.incoming_calls.v2';
  static const _activeChannelId = 'polycule.active_calls';
  static const _androidCallChannel = MethodChannel('polycule.calls');

  static final pendingIntent = ValueNotifier<CallNotificationIntent?>(null);
  static bool _requestedFullScreenPermission = false;

  /// Android 14+ may require the user to explicitly allow call full-screen
  /// intents. Outgoing call initiation is a foreground, user-driven moment in
  /// which opening that system permission screen is safe.
  static Future<bool?> requestFullScreenIntentPermission() async {
    if (kIsWeb || !Platform.isAndroid) {
      return true;
    }
    if (_requestedFullScreenPermission) {
      return null;
    }
    try {
      final result = await FlutterLocalNotificationsPlugin()
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestFullScreenIntentPermission();
      if (result != null) {
        _requestedFullScreenPermission = true;
      }
      return result;
    } catch (error) {
      debugPrint('Unable to request full-screen call permission: $error');
      return false;
    }
  }

  static int notificationId(String callId) {
    var hash = 0x811c9dc5;
    for (final unit in callId.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash | 0x20000000;
  }

  static String payload({
    required int clientIdentifier,
    required String roomId,
    required String callId,
  }) =>
      jsonEncode({
        'kind': 'call',
        'client': clientIdentifier,
        'room': roomId,
        'call': callId,
      });

  static CallNotificationIntent? receiveResponse(
    String? payload, {
    String? actionId,
  }) {
    if (payload == null) {
      return null;
    }
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['kind'] != 'call') {
        return null;
      }
      final client = data['client'];
      final room = data['room'];
      final call = data['call'];
      if (client is! int || room is! String || call is! String) {
        return null;
      }
      final action = switch (actionId) {
        answerActionId => CallNotificationAction.answer,
        declineActionId => CallNotificationAction.decline,
        hangupActionId => CallNotificationAction.hangup,
        _ => CallNotificationAction.show,
      };
      final intent = CallNotificationIntent(
        clientIdentifier: client,
        roomId: room,
        callId: call,
        action: action,
      );
      pendingIntent.value = intent;
      return intent;
    } catch (_) {
      return null;
    }
  }

  static void clearPending(CallNotificationIntent intent) {
    if (identical(pendingIntent.value, intent)) {
      pendingIntent.value = null;
    }
  }

  static Future<void> showIncoming({
    required int clientIdentifier,
    required String roomId,
    required String callId,
    required String callerName,
    required bool video,
    required Duration timeout,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    await CallLogJournal.record('Posting native incoming-call notification.');
    try {
      await _androidCallChannel.invokeMethod<void>(
        'ensureIncomingCallChannel',
      );
    } on PlatformException catch (error) {
      debugPrint('Unable to configure the Android ringtone channel: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Android ringtone channel plugin is unavailable: $error');
    }
    final plugin = FlutterLocalNotificationsPlugin();
    final callPayload = payload(
      clientIdentifier: clientIdentifier,
      roomId: roomId,
      callId: callId,
    );
    try {
      await plugin.show(
        notificationId(callId),
        callerName,
        video ? 'Incoming video call' : 'Incoming call',
        NotificationDetails(
          android: AndroidNotificationDetails(
            _incomingChannelId,
            'Incoming calls',
            channelDescription: 'Incoming Matrix calls',
            category: AndroidNotificationCategory.call,
            importance: Importance.max,
            priority: Priority.max,
            visibility: NotificationVisibility.public,
            fullScreenIntent: true,
            ongoing: true,
            autoCancel: false,
            timeoutAfter: timeout.inMilliseconds,
            playSound: true,
            enableVibration: true,
            audioAttributesUsage: AudioAttributesUsage.notificationRingtone,
            additionalFlags: Int32List.fromList(const [4]),
            icon: '@drawable/ic_launcher_foreground',
            actions: const [
              AndroidNotificationAction(
                declineActionId,
                'Decline',
                showsUserInterface: true,
                cancelNotification: false,
                semanticAction: SemanticAction.delete,
              ),
              AndroidNotificationAction(
                answerActionId,
                'Answer',
                showsUserInterface: true,
                cancelNotification: false,
                semanticAction: SemanticAction.call,
              ),
            ],
          ),
        ),
        payload: callPayload,
      );
      await CallLogJournal.record(
        'Native incoming-call notification posted successfully.',
        important: true,
      );
    } catch (error) {
      await CallLogJournal.record(
        'Native incoming-call notification failed (${error.runtimeType}).',
        level: Level.error,
      );
      rethrow;
    }
  }

  static Future<void> showOngoing({
    required int clientIdentifier,
    required String roomId,
    required String callId,
    required String peerName,
    required bool connected,
  }) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    await FlutterLocalNotificationsPlugin().show(
      notificationId(callId),
      peerName,
      connected ? 'Call in progress' : 'Connecting call…',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _activeChannelId,
          'Active calls',
          channelDescription: 'Ongoing Matrix calls',
          category: AndroidNotificationCategory.call,
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          playSound: false,
          enableVibration: false,
          usesChronometer: connected,
          when: connected ? DateTime.now().millisecondsSinceEpoch : null,
          audioAttributesUsage: AudioAttributesUsage.voiceCommunication,
          icon: '@drawable/ic_launcher_foreground',
          actions: const [
            AndroidNotificationAction(
              hangupActionId,
              'Hang up',
              showsUserInterface: true,
              cancelNotification: false,
              semanticAction: SemanticAction.delete,
            ),
          ],
        ),
      ),
      payload: payload(
        clientIdentifier: clientIdentifier,
        roomId: roomId,
        callId: callId,
      ),
    );
  }

  static Future<void> cancel(String callId) {
    if (kIsWeb || !Platform.isAndroid) {
      return Future.value();
    }
    return FlutterLocalNotificationsPlugin().cancel(notificationId(callId));
  }
}
