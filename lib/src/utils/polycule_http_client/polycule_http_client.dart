import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart';

import '../../widgets/settings_manager.dart';
import '../version.dart';

import 'polycule_http_client_web.dart'
    if (dart.library.io) 'polycule_http_client_io.dart';

typedef ClientCallback = Client Function();

abstract class PolyculeHttpClientManager {
  const PolyculeHttpClientManager._();

  static const userAgent =
      'polycule/${Version.version} (+${Version.gitlabRepoBase})';
  static const cacheSize = 64 * 1024 * 1024;

  static void init(ValueListenable<NetworkState> settings) {
    _buildHttpClient(settings.value);
    settings.addListener(() => _buildHttpClient(settings.value));
  }

  static final StreamController<ClientCallback> _clientController =
      StreamController<ClientCallback>.broadcast();

  static Stream<ClientCallback> get httpClientCallbackStream =>
      _clientController.stream;

  static void _buildHttpClient(NetworkState settings) {
    updateHttpClientSettings(settings);
    _clientController.add(getHttpClientPlatformCallback());
  }
}
