import 'package:http/http.dart' hide Client;
import 'package:matrix/matrix.dart';

class MatrixRefreshTokenClient extends BaseClient {
  MatrixRefreshTokenClient({
    required this.inner,
    required this.client,
  });

  final Client client;
  final BaseClient inner;

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    Request? req;
    if ( // only refresh if
        // we are actually initialized
        client.onSync.value != null &&
            // the request is to the homeserver rather than e.g. IDP
            request.url.host == client.homeserver?.host &&
            // the request is authenticated
            request.headers
                .map((k, v) => MapEntry(k.toLowerCase(), v))
                .containsKey('authorization') &&
            // and last but not least we're logged in
            client.isLogged()) {
      try {
        await client.ensureNotSoftLoggedOut();
      } catch (_) {
      }
      // in every case ensure we run with the latest bearer token to avoid
      // race conditions
      finally {
        final headers = request.headers;
        // hours wasted : unknown :facepalm:
        headers.removeWhere((k, _) => k.toLowerCase() == 'authorization');
        headers['Authorization'] = 'Bearer ${client.bearerToken!}';
        req = Request(request.method, request.url);
        req.headers.addAll(headers);
        if (request is Request) {
          req.bodyBytes = request.bodyBytes;
        }
      }
    }
    return inner.send(req ?? request);
  }
}
