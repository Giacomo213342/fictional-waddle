import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../settings_interface.dart';
import 'push_gateway_extension.dart';
import 'push_handler.dart';

final pusherDataMessageFormat = kIsWeb
    ? null
    : Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : null;

class PushManager {
  PushManager(this.client, this.localizations) {
    unawaited(_initialize());
  }

  final settings = const SettingsInterface();
  final Client client;
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  AppLocalizations localizations;

  String get instance => client.clientName;

  String? endpoint;

  Future<void> _initialize() async {
    try {
      await UnifiedPush.initialize(
        onNewEndpoint: onNewEndpoint,
        onRegistrationFailed: onRegistrationFailed,
        onUnregistered: onUnregistered,
        onMessage: onMessage,
      );
    } on UnimplementedError catch (_) {}
  }

  Future<void> onNewEndpoint(String endpoint, String instance) async {
    if (instance != this.instance) {
      return;
    }
    // You should send the endpoint to your application server
    // and sync for missing notifications.
    final uri = await client.checkPushGateway(endpoint);
    final pushKey = endpoint;
    final pushId = pushKey.split('/').last;

    final pusher = Pusher(
      appId: 'business.braid.polycule',
      pushkey: pushKey,
      appDisplayName: localizations.appName,
      data: PusherData(
        url: uri,
        format: 'event_id_only',
        additionalProperties: {'data_message': pusherDataMessageFormat},
      ),
      deviceDisplayName:
          '${client.deviceName ?? localizations.appName} - $pushId',
      kind: 'http',
      lang: localizations.language.replaceAll('_', '-'),
    );

    await client.postPusher(
      pusher,
    );
    await settings.storePushKey(client.clientName, pushKey);
  }

  void onRegistrationFailed(String instance) {
    if (instance != this.instance) {
      return;
    }
  }

  Future<void> unregister() async {
    await UnifiedPush.unregister(instance);
  }

  Future<void> onUnregistered(String instance) async {
    if (instance != this.instance) {
      return;
    }
    final pushKey = await settings.getPushKey(client.clientName);
    if (pushKey == null) {
      return;
    }

    await client.deletePusher(
      PusherId(
        appId: 'business.braid.polycule',
        pushkey: pushKey,
      ),
    );
  }

  Future<void> onMessage(Uint8List message, String instance) async {
    if (instance != this.instance) {
      return;
    }
    final content = utf8.decode(message);
    final json = jsonDecode(content);
    final data = Map<String, dynamic>.from(
      json['notification'],
    );
    final notification = PushNotification.fromJson(data);

    await handlePushNotification(
      client: client,
      notification: notification,
      l10n: localizations,
    );
  }

  Future<void> register() async {
    final permission = kIsWeb || !Platform.isAndroid
        ? true
        : await notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
    if (permission == null) {
      return;
    }
    await UnifiedPush.registerApp(instance);
  }
}
