import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:polycule/src/utils/matrix/voip/polycule_voip.dart';

void main() {
  TurnServerCredentials credentials({int ttl = 100}) => TurnServerCredentials(
        password: 'secret',
        ttl: ttl,
        uris: ['turn:relay.invalid'],
        username: 'user',
      );

  test('TURN credentials are reused only inside their safe TTL', () async {
    var now = DateTime.utc(2026, 7, 17);
    var loads = 0;
    final cache = TurnCredentialCache(
      now: () => now,
      load: () async {
        loads++;
        return credentials();
      },
    );

    await cache.resolve();
    now = now.add(const Duration(seconds: 89));
    await cache.resolve();
    expect(loads, 1);

    now = now.add(const Duration(seconds: 2));
    await cache.resolve();
    expect(loads, 2);
  });

  test('concurrent TURN lookups share one request', () async {
    final completer = Completer<TurnServerCredentials>();
    var loads = 0;
    final cache = TurnCredentialCache(load: () {
      loads++;
      return completer.future;
    });

    final first = cache.resolve();
    final second = cache.resolve();
    expect(loads, 1);
    completer.complete(credentials());
    expect(await first, same(await second));
  });

  test('zero TTL is refreshed immediately', () async {
    var loads = 0;
    final cache = TurnCredentialCache(load: () async {
      loads++;
      return credentials(ttl: 0);
    });

    await cache.resolve();
    await cache.resolve();
    expect(loads, 2);
  });
}
