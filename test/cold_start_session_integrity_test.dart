import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('temporary storage failures cannot erase session material', () {
    final cipher = File(
      'lib/src/utils/matrix/database/cipher.dart',
    ).readAsStringSync();
    final database = File(
      'lib/src/utils/matrix/database/polycule_database_builder.dart',
    ).readAsStringSync();
    final clients = File(
      'lib/src/widgets/matrix/client_manager/client_store.dart',
    ).readAsStringSync();

    expect(cipher, isNot(contains('kPolyculeSecureStorage.delete')));
    expect(database, isNot(contains('deleteDatabase')));
    expect(database, contains('The original database was preserved'));
    expect(clients, isNot(contains('on PlatformException')));
  });

  test('foreground and headless clients share one Matrix store lease', () {
    final foreground = File(
      'lib/src/widgets/matrix/client_manager/client_manager.dart',
    ).readAsStringSync();
    final background = File(
      'lib/src/utils/matrix/push_handler.dart',
    ).readAsStringSync();

    expect(foreground, contains('MatrixStoreLease.acquire()'));
    expect(background, contains('MatrixStoreLease.acquire()'));
    expect(foreground, contains('lease.release()'));
    expect(background, contains('storeLease?.release()'));
  });

  test('store ownership is released by the kernel after process death', () {
    final lease = File(
      'lib/src/utils/matrix/database/matrix_store_lease.dart',
    ).readAsStringSync();

    final nativeLock = File(
      'android/app/src/main/kotlin/business/braid/polycule/'
      'MatrixStoreLockPlugin.kt',
    ).readAsStringSync();
    expect(lease, contains("'polycule.matrix_store_lock'"));
    expect(nativeLock, contains('Semaphore(1, true)'));
    expect(nativeLock, contains('onDetachedFromEngine'));
    expect(nativeLock, contains('storeSemaphore.release'));
    expect(lease, isNot(contains('Timer.periodic')));
    expect(lease, isNot(contains('_maximumLeaseAge')));
  });

  test('encrypted stores have verified rolling recovery snapshots', () {
    final database = File(
      'lib/src/utils/matrix/database/polycule_database_builder.dart',
    ).readAsStringSync();

    expect(database, contains('PRAGMA journal_mode = WAL'));
    expect(database, contains('PRAGMA busy_timeout = 15000'));
    expect(database, contains('PRAGMA synchronous = FULL'));
    expect(database, contains('PRAGMA quick_check(1)'));
    expect(database, contains('VACUUM INTO'));
    expect(database, contains("_primaryRecoverySuffix = '.recovery-1'"));
    expect(database, contains("_secondaryRecoverySuffix = '.recovery-2'"));
    expect(database, contains('_candidateContainsStoredSession'));
    expect(database, contains('_isTransientDatabaseError'));
  });

  test('a malformed client index falls back to preserved account stores', () {
    final clients = File(
      'lib/src/widgets/matrix/client_manager/client_store.dart',
    ).readAsStringSync();

    expect(clients, contains('on FormatException'));
    expect(clients, contains('discovering preserved stores'));
    expect(clients, contains('discoverStoredClientIdentifiers()'));
  });

  test('call pushes bypass message fallback and persist native actions', () {
    final pushHandler = File(
      'lib/src/utils/matrix/push_handler.dart',
    ).readAsStringSync();
    final actionStore = File(
      'third_party/polycule_call_notifications/android/src/main/kotlin/'
      'business/braid/polycule/callnotifications/CallActionStore.kt',
    ).readAsStringSync();
    final activity = File(
      'third_party/polycule_call_notifications/android/src/main/kotlin/'
      'business/braid/polycule/callnotifications/IncomingCallActivity.kt',
    ).readAsStringSync();
    final contract = File(
      'third_party/polycule_call_notifications/android/src/main/kotlin/'
      'business/braid/polycule/callnotifications/CallNotificationContract.kt',
    ).readAsStringSync();

    expect(pushHandler, contains('_handleCallSignalingPush'));
    expect(
      pushHandler.indexOf('_handleCallSignalingPush('),
      lessThan(pushHandler.indexOf('Future<bool> showFallback()')),
    );
    expect(actionStore, contains('.commit()'));
    expect(activity, contains('CallActionStore.persist'));
    expect(contract, contains('polycule.incoming_calls.v5'));
  });
}
