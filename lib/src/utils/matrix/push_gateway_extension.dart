import 'dart:convert';

import 'package:matrix/matrix.dart';

final _defaultPushEndpoint = Uri.https(
  'matrix.gateway.unifiedpush.org',
  '_matrix/push/v1/notify',
);

extension PushGatewayExtension on Client {
  Future<Uri> checkPushGateway(String endpoint) async {
    final endpointUri = Uri.parse(endpoint);
    final uri = Uri.https(
      endpointUri.host,
      '/_matrix/push/v1/notify',
    );
    try {
      final response = await httpClient.get(uri);
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['gateway'] == 'matrix' ||
            (json['unifiedpush'] is Map &&
                json['unifiedpush']['gateway'] == 'matrix')) {
          return uri;
        }
      }
      return _defaultPushEndpoint;
    } catch (e, s) {
      Logs().w('Push gateway error', e, s);
    }
    return _defaultPushEndpoint;
  }
}
