import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:polycule/src/utils/matrix/matrix_auth_retry_client.dart';

void main() {
  final homeserver = Uri.parse('https://matrix.example');

  test('retries an authenticated homeserver 401 three times', () async {
    var requests = 0;
    final client = MatrixAuthRetryClient(
      inner: MockClient((request) async {
        requests++;
        return Response(
          '{"errcode":"M_UNKNOWN_TOKEN"}',
          401,
          request: request,
        );
      }),
      homeserver: () => homeserver,
      delays: const [Duration.zero, Duration.zero, Duration.zero],
    );

    final response = await client.get(
      homeserver.resolve('/_matrix/client/v3/sync'),
      headers: {'Authorization': 'Bearer token'},
    );

    expect(response.statusCode, 401);
    expect(requests, 4);
  });

  test('does not retry unauthenticated or foreign 401 responses', () async {
    var requests = 0;
    final client = MatrixAuthRetryClient(
      inner: MockClient((request) async {
        requests++;
        return Response('unauthorized', 401, request: request);
      }),
      homeserver: () => homeserver,
      delays: const [Duration.zero, Duration.zero, Duration.zero],
    );

    await client.get(homeserver.resolve('/_matrix/client/versions'));
    await client.get(
      Uri.parse('https://elsewhere.example/resource'),
      headers: {'Authorization': 'Bearer token'},
    );

    expect(requests, 2);
  });

  test('does not retry authenticated non-401 responses', () async {
    var requests = 0;
    final client = MatrixAuthRetryClient(
      inner: MockClient((request) async {
        requests++;
        return Response('temporary', 503, request: request);
      }),
      homeserver: () => homeserver,
      delays: const [Duration.zero, Duration.zero, Duration.zero],
    );

    await client.get(
      homeserver.resolve('/_matrix/client/v3/sync'),
      headers: {'Authorization': 'Bearer token'},
    );

    expect(requests, 1);
  });
}
