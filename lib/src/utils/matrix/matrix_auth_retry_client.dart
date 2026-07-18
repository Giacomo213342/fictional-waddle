import 'package:http/http.dart';
import 'package:http/retry.dart';

typedef HomeserverProvider = Uri? Function();

/// Retries only authenticated 401 responses from the active homeserver.
///
/// Retrying broader failures here could duplicate non-idempotent Matrix
/// operations. Network and 5xx refresh failures are handled by
/// [SessionRefreshRetrier], while the Matrix sync loop already retries
/// connection failures without logging out.
class MatrixAuthRetryClient extends BaseClient {
  MatrixAuthRetryClient({
    required BaseClient inner,
    required HomeserverProvider homeserver,
    Iterable<Duration> delays = const [
      Duration(milliseconds: 250),
      Duration(milliseconds: 500),
      Duration(seconds: 1),
    ],
  }) : _inner = RetryClient.withDelays(
          inner,
          delays,
          when: (response) => shouldRetryUnauthorized(
            response,
            homeserver(),
          ),
          whenError: (_, __) => false,
        );

  final RetryClient _inner;

  static bool shouldRetryUnauthorized(
    BaseResponse response,
    Uri? homeserver,
  ) {
    final request = response.request;
    if (response.statusCode != 401 || request == null || homeserver == null) {
      return false;
    }
    final authenticated = request.headers.keys.any(
      (header) => header.toLowerCase() == 'authorization',
    );
    return authenticated &&
        request.url.scheme == homeserver.scheme &&
        request.url.host == homeserver.host &&
        request.url.port == homeserver.port;
  }

  @override
  Future<StreamedResponse> send(BaseRequest request) => _inner.send(request);

  @override
  void close() => _inner.close();
}
