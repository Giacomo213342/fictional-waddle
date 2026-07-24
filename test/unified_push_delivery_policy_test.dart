import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/push_handler.dart';

void main() {
  test('background fallback is bounded below one second', () {
    expect(
      backgroundFastFallbackDelay,
      lessThan(const Duration(seconds: 1)),
    );
  });

  test('slow callbacks cannot serialize later notification delivery', () {
    final handler = File(
      'lib/src/utils/matrix/push_handler.dart',
    ).readAsStringSync();

    expect(handler, isNot(contains('_backgroundNotificationQueues')));
    expect(
      handler,
      contains('handleBackgroundNotification(message, instance).catchError'),
    );
    expect(handler, contains('Timer('));
    expect(handler, contains('backgroundFastFallbackDelay'));
  });

  test('native service persistently drops identical payloads first', () {
    final service = File(
      'third_party/unifiedpush_android/android/src/main/kotlin/'
      'org/unifiedpush/flutter/connector/UnifiedPushService.kt',
    ).readAsStringSync();

    expect(
      service.indexOf('if (isDuplicatePush(message, instance))'),
      lessThan(service.indexOf('Plugin.calls?.emit')),
    );
    expect(service, contains('MessageDigest.getInstance("SHA-256")'));
    expect(service, contains('.optString("event_id")'));
    expect(service, contains('DUPLICATE_WINDOW_MS'));
    expect(service, contains('editor.commit()'));
  });
}
