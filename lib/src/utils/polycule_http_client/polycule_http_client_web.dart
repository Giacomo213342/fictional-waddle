import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart';

import '../../widgets/settings_manager.dart';
import 'polycule_http_client.dart';

void updateHttpClientSettings(NetworkState settings) {}

ClientCallback getHttpClientPlatformCallback() {
  return _buildFetchClient;
}

Client _buildFetchClient() {
  return FetchClient(
    streamRequests: true,
  );
}
