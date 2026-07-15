import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matrix/matrix.dart';
import 'package:unifiedpush/unifiedpush.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/intent_manager.dart';
import '../settings_interface.dart';
import '../unified_push/unified_push_storage_polycule.dart';
import 'push_gateway_extension.dart';
import 'push_handler.dart';

final pusherDataMessageFormat = kIsWeb
    ? null
    : Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : Platform.isLinux
                ? 'android'
                : null;

class PushManager {
  PushManager(this.client) {
    unawaited(_initialize());
  }

  static Future<void>? _notificationInitialization;

  static Future<void> initializeNotificationPlugin(
    AppLocalizations l10n,
  ) {
    final current = _notificationInitialization;
    if (current != null) {
      return current;
    }
    final initialization = _initializeNotificationPlugin(l10n);
    _notificationInitialization = initialization;
    initialization.catchError((Object _) {
      if (identical(_notificationInitialization, initialization)) {
        _notificationInitialization = null;
      }
    });
    return initialization;
  }

  static Future<void> _initializeNotificationPlugin(
    AppLocalizations l10n,
  ) async {
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
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    final launchDetails =
        await notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _openNotificationPayload(launchDetails?.notificationResponse?.payload);
    }
  }

  static void _handleNotificationResponse(NotificationResponse response) {
    _openNotificationPayload(response.payload);
  }

  static void _openNotificationPayload(String? payload) {
    if (payload == null) {
      return;
    }
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final client = data['client'];
      final room = data['room'];
      if (client is int && room is String) {
        IntentManager.notificationRouteListener.value =
            '/client/$client/rooms/${Uri.encodeComponent(room)}';
      }
    } catch (_) {
      // Ignore payloads produced by older app versions.
    }
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
        linuxOptions: LinuxOptions(
          dbusName: 'business.braid.polycule',
          storage: UnifiedPushStoragePolycule(),
          background: false,
        ),
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
    // fallback on https://matrix.gateway.unifiedpush.org/_matrix/push/v1/notify
    final uri = await client.checkPushGateway(endpoint.url);
    final pushKey = endpoint.url;
    final pushId = pushKey.split('/').last;

    final pusher = Pusher(
      appId: 'business.braid.polycule.${client.deviceID}',
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
        appId: 'business.braid.polycule.${client.deviceID}',
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
