import 'dart:io';

import 'package:flutter/services.dart';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import '../../widgets/settings_manager.dart';
import '../assets.dart';
import 'polycule_http_client.dart';
import 'package:socks5_proxy/socks_client.dart';

URLSessionConfiguration _cupertinoConfig =
    URLSessionConfiguration.defaultSessionConfiguration();

SecurityContext _ioContext = SecurityContext.defaultContext;
NetworkState? _currentSettings;
InternetAddress? _socks5Address;

Future<void> updateHttpClientSettings(NetworkState settings) async {
  _currentSettings = settings;
  if (settings.useSocks5Proxy && settings.proxyHost != null && settings.proxyHost!.isNotEmpty) {
    _socks5Address = InternetAddress.tryParse(settings.proxyHost!);
    if (_socks5Address == null) {
      try {
        final addresses = await InternetAddress.lookup(settings.proxyHost!);
        if (addresses.isNotEmpty) {
          _socks5Address = addresses.first;
        }
      } catch (_) {
        // failed to lookup
      }
    }
  }
  if (Platform.isIOS || Platform.isMacOS) {
    _cupertinoConfig = URLSessionConfiguration.ephemeralSessionConfiguration()
      ..cache = URLCache.withCapacity(
        memoryCapacity: PolyculeHttpClientManager.cacheSize,
      )
      ..httpAdditionalHeaders = {
        'User-Agent': PolyculeHttpClientManager.userAgent,
      };
  } else {
    _ioContext = SecurityContext.defaultContext;
    try {
      // Let's Encrypt on Android 6
      // Certificate details: https://crt.sh/?id=9314791
      final isrgX1 = await rootBundle.load(Assets.isrgX1.name);
      _ioContext.setTrustedCertificatesBytes(Uint8List.sublistView(isrgX1));
    } on TlsException catch (e) {
      if (e.osError != null &&
          e.osError!.message.contains('CERT_ALREADY_IN_HASH_TABLE')) {
      } else {
        rethrow;
      }
    }
    _ioContext.minimumTlsProtocolVersion = switch (settings.tlsMinVersion) {
      0x0303 => TlsProtocolVersion.tls1_2,
      0x0304 => TlsProtocolVersion.tls1_3,
      _ => TlsProtocolVersion.tls1_2,
    };
    _ioContext.allowLegacyUnsafeRenegotiation = false;
  }
}

ClientCallback getHttpClientPlatformCallback() {
  if (Platform.isIOS || Platform.isMacOS) {
    return _buildCupertinoClient;
  } else {
    return _buildIoClient;
  }
}

BaseClient _buildCupertinoClient() {
  return CupertinoClient.fromSessionConfiguration(_cupertinoConfig);
}

BaseClient _buildIoClient() {
  final client = HttpClient(context: _ioContext)
    ..userAgent = PolyculeHttpClientManager.userAgent;

  if (_currentSettings?.useSocks5Proxy == true && _socks5Address != null && _currentSettings?.proxyPort != null) {
    SocksTCPClient.assignToHttpClient(
      client,
      [
        ProxySettings(
          _socks5Address!,
          _currentSettings!.proxyPort!,
          password: _currentSettings?.proxyPassword ?? '',
          username: _currentSettings?.proxyUsername ?? '',
        )
      ]
    );
  } else if (_currentSettings?.permitProxy == false) {
    client.findProxy = (url) => 'DIRECT';
  }

  return IOClient(client);
}
