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
    expect(contract, contains('polycule.incoming_calls.v4'));
  });
}
