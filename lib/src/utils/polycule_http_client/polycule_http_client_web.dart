import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart';

import '../../widgets/settings_manager.dart';
import 'polycule_http_client.dart';

ClientCallback buildHttpClient(NetworkState settings) {
  return _buildFetchClient;
}

Client _buildFetchClient() {
  return FetchClient(
    streamRequests: true,
  );
}
