import 'package:flutter/foundation.dart';

import 'package:http/http.dart';

import '../../widgets/settings_manager.dart';
import '../version.dart';

import 'polycule_http_client_web.dart'
    if (dart.library.io) 'polycule_http_client_io.dart';

typedef ClientCallback = Client Function();

abstract class PolyculeHttpClient {
  const PolyculeHttpClient._();

  static const userAgent =
      'polycule/${Version.version} (+${Version.gitlabRepoBase})';
  static const cacheSize = 64 * 1024 * 1024;

  static void init(ValueListenable<NetworkState> settings) {
    _buildHttpClient(settings.value);
    settings.addListener(() => _buildHttpClient(settings.value));
  }

  static final ValueNotifier<ClientCallback> _clientNotifier =
      ValueNotifier(_stubCallback);

  static ValueListenable<ClientCallback> get httpClient => _clientNotifier;

  static void _buildHttpClient(NetworkState settings) {
    _clientNotifier.value = buildHttpClient(settings);
    return;
  }

  static Never _stubCallback() => throw UnimplementedError();
}
