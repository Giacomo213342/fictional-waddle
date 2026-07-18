import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/database/cipher.dart';
import 'package:polycule/src/utils/matrix/database/matrix_store_lease.dart';
import 'package:polycule/src/utils/matrix/database/polycule_database_builder.dart';

void main() {
  test('keeps the existing cipher without writing', () async {
    var writes = 0;
    final cipher = await getDatabaseCipher(
      databaseExists: true,
      read: (_) async => 'existing-cipher',
      write: (_, __) async => writes++,
    );

    expect(cipher, 'existing-cipher');
    expect(writes, 0);
  });

  test('never generates a replacement key for an existing database', () async {
    var writes = 0;

    await expectLater(
      getDatabaseCipher(
        databaseExists: true,
        read: (_) async => null,
        write: (_, __) async => writes++,
      ),
      throwsA(isA<MissingDatabaseCipherError>()),
    );
    expect(writes, 0);
  });

  test('propagates transient secure storage reads without mutation', () async {
    var writes = 0;
    final failure = StateError('temporarily unavailable');

    await expectLater(
      getDatabaseCipher(
        databaseExists: true,
        read: (_) => Future<String?>.error(failure),
        write: (_, __) async => writes++,
      ),
      throwsA(same(failure)),
    );
    expect(writes, 0);
  });

  test('creates and verifies a key only for a new database', () async {
    String? stored;
    final cipher = await getDatabaseCipher(
      databaseExists: false,
      read: (_) async => stored,
      write: (_, value) async => stored = value,
    );

    expect(cipher, isNotEmpty);
    expect(stored, cipher);
  });

  test('Matrix store leases serialize concurrent owners', () async {
    final directory = await Directory.systemTemp.createTemp('polycule-lease');
    addTearDown(() => directory.delete(recursive: true));
    final lockFile = File('${directory.path}/matrix-store.lock');
    final first = await MatrixStoreLease.acquireFile(lockFile);
    var secondAcquired = false;
    final secondFuture = MatrixStoreLease.acquireFile(lockFile).then((lease) {
      secondAcquired = true;
      return lease;
    });

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(secondAcquired, isFalse);

    await first.release();
    final second = await secondFuture.timeout(const Duration(seconds: 2));
    expect(secondAcquired, isTrue);
    await second.release();
  });

  test('discovers client databases when the secure registry is missing',
      () async {
    final directory = await Directory.systemTemp.createTemp('polycule-clients');
    addTearDown(() => directory.delete(recursive: true));
    await File('${directory.path}/polycule_client_4.sqlite').create();
    await File('${directory.path}/polycule_client_2.sqlite.broken').create();
    await File('${directory.path}/polycule_client_8.sqlite.failed-open-1')
        .create();

    expect(
      await discoverStoredClientIdentifiers(directory: directory),
      const [2, 4],
    );
  });
}
