import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart';

import '../../widgets/settings_manager.dart';
import '../dart_environment.dart';
import '../version.dart';

import 'polycule_http_client_web.dart'
    if (dart.library.io) 'polycule_http_client_io.dart';

typedef ClientCallback = BaseClient Function();

abstract class PolyculeHttpClientManager {
  const PolyculeHttpClientManager._();

  static Completer<void>? _initFuture;

  static const userAgent =
      'polycule/${DartEnvironment.polyculeVersion} (+${Version.gitlabRepoBase})';
  static const cacheSize = 64 * 1024 * 1024;

  static Future<void> init(ValueListenable<NetworkState> settings) async {
    final started = _initFuture;
    if (started != null) {
      return started.future;
    }
    _initFuture = Completer<void>();
    await _buildHttpClient(settings.value);
    settings.addListener(() => _buildHttpClient(settings.value));
    _initFuture?.complete();
  }

  static final StreamController<ClientCallback> _clientController =
      StreamController<ClientCallback>.broadcast();

  static Stream<ClientCallback> get httpClientCallbackStream =>
      _clientController.stream;

  static Future<void> _buildHttpClient(NetworkState settings) async {
    await updateHttpClientSettings(settings);
    _clientController.add(getHttpClientPlatformCallback());
  }
}
