import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart';
import 'package:web/web.dart' show window;

import '../../widgets/settings_manager.dart';
import 'polycule_http_client.dart';

Future<void> updateHttpClientSettings(NetworkState settings) async {
  // facepalm
  return Future.delayed(const Duration(milliseconds: 0));
}

ClientCallback getHttpClientPlatformCallback() {
  return _buildFetchClient;
}

BaseClient _buildFetchClient() {
  final appVersion = window.navigator.appVersion;
  return FetchClient(
    mode: RequestMode.cors,
    credentials: RequestCredentials.omit,
    cache: RequestCache.noStore,
    referrerPolicy: RequestReferrerPolicy.strictOriginWhenCrossOrigin,
    streamRequests: appVersion.contains('Chrome'),
  );
}
