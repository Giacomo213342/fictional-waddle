import 'dart:io';

import 'package:flutter/services.dart';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import '../../widgets/settings_manager.dart';
import 'polycule_http_client.dart';

URLSessionConfiguration _cupertinoConfig =
    URLSessionConfiguration.defaultSessionConfiguration();

SecurityContext _ioContext = SecurityContext.defaultContext;

Future<void> updateHttpClientSettings(NetworkState settings) async {
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
      final isrgX1 = await rootBundle.load('assets/ca/isrgrootx1.pem');
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

Client _buildCupertinoClient() {
  return CupertinoClient.fromSessionConfiguration(_cupertinoConfig);
}

Client _buildIoClient() {
  return IOClient(
    HttpClient(context: _ioContext)
      ..userAgent = PolyculeHttpClientManager.userAgent,
  );
}
