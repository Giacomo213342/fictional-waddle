import 'dart:convert';
import 'dart:io';

import 'package:cupertino_http/cupertino_http.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import '../../widgets/settings_manager.dart';
import '../isrg_x1.dart';
import 'polycule_http_client.dart';

URLSessionConfiguration _cupertinoConfig =
    URLSessionConfiguration.defaultSessionConfiguration();

SecurityContext _ioContext = SecurityContext.defaultContext;

void updateHttpClientSettings(NetworkState settings) {
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
      final bytes = utf8.encode(ISRG_X1);
      _ioContext.setTrustedCertificatesBytes(bytes);
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
