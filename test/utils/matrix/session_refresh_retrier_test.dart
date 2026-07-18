import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:polycule/src/utils/matrix/session_refresh_retrier.dart';

void main() {
  test('retries transient failures three times before the long pause',
      () async {
    var attempts = 0;
    final delays = <Duration>[];
    final retrier = SessionRefreshRetrier(
      delay: (duration) async => delays.add(duration),
    );

    await retrier.run(() async {
      attempts++;
      if (attempts < 5) throw const SocketException('offline');
    });

    expect(attempts, 5);
    expect(delays, const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(minutes: 1),
    ]);
  });

  test('does not treat other homeserver errors as invalid sessions', () async {
    var attempts = 0;
    final retrier = SessionRefreshRetrier(
      delay: (_) async {},
    );

    await retrier.run(() async {
      attempts++;
      if (attempts == 1) {
        throw MatrixException.fromJson({
          'errcode': 'M_LIMIT_EXCEEDED',
          'error': 'Temporary failure',
        });
      }
    });

    expect(attempts, 2);
  });

  test('propagates only a confirmed unknown token without retrying', () async {
    var attempts = 0;
    final retrier = SessionRefreshRetrier(delay: (_) async {});
    final invalidToken = MatrixException.fromJson({
      'errcode': 'M_UNKNOWN_TOKEN',
      'error': 'Invalid refresh token',
    });

    await expectLater(
      retrier.run(() async {
        attempts++;
        throw invalidToken;
      }),
      throwsA(same(invalidToken)),
    );
    expect(attempts, 1);
  });
}
