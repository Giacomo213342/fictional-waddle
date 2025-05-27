import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

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
  PushManager(this.client) {
    unawaited(_initialize());
  }

  static bool _notificationsInitialized = false;

  static Future<void> initializeNotificationPlugin(
    AppLocalizations l10n,
  ) async {
    if (_notificationsInitialized) {
      return;
    }
    _notificationsInitialized = true;

    final notificationsPlugin = FlutterLocalNotificationsPlugin();

    await notificationsPlugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings(
          '@drawable/ic_launcher_foreground',
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: l10n.view,
          defaultIcon: ThemeLinuxIcon('business.braid.polycule'),
        ),
        iOS: const DarwinInitializationSettings(),
        macOS: const DarwinInitializationSettings(),
      ),
    );
  }

  final settings = const SettingsInterface();
  final Client client;
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  late AppLocalizations localizations;

  String get instance => client.clientName;

  String? endpoint;

  Future<void> _initialize() async {
    final locale = WidgetsBinding.instance.platformDispatcher
            .computePlatformResolvedLocale(AppLocalizations.supportedLocales) ??
        const Locale('en');
    localizations = await AppLocalizations.delegate.load(locale);
    await initializeNotificationPlugin(localizations);
    try {
      final registered = await UnifiedPush.initialize(
        onNewEndpoint: onNewEndpoint,
        onRegistrationFailed: onRegistrationFailed,
        onUnregistered: onUnregistered,
        onMessage: onMessage,
      );
      if (registered || await UnifiedPush.tryUseCurrentOrDefaultDistributor()) {
        await register();
      }
    } on UnimplementedError catch (_) {}
  }

  Future<void> onNewEndpoint(PushEndpoint endpoint, String instance) async {
    if (instance != this.instance) {
      return;
    }
    // You should send the endpoint to your application server
    // and sync for missing notifications.
    final uri = await client.checkPushGateway(endpoint.url);
    final pushKey = endpoint.url;
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

  void onRegistrationFailed(FailedReason reason, String instance) {
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

  Future<void> onMessage(PushMessage message, String instance) async {
    if (instance != client.clientName) {
      return;
    }
    await handlePushNotification(
      client: client,
      l10n: localizations,
      message: message.content,
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
    await UnifiedPush.register(instance: instance);
  }
}
