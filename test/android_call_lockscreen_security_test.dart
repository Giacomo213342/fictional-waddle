import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the complete Flutter activity is never exposed above the keyguard', () {
    final source = File(
      'android/app/src/main/kotlin/business/braid/polycule/MainActivity.kt',
    ).readAsStringSync();
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    for (final forbidden in const [
      'setShowWhenLocked',
      'setTurnScreenOn',
      'FLAG_SHOW_WHEN_LOCKED',
      'FLAG_DISMISS_KEYGUARD',
      'FLAG_TURN_SCREEN_ON',
    ]) {
      expect(source, isNot(contains(forbidden)), reason: forbidden);
      expect(manifest, isNot(contains(forbidden)), reason: forbidden);
    }
    expect(manifest, isNot(contains('android:showWhenLocked="true"')));
    expect(manifest, isNot(contains('android:turnScreenOn="true"')));
  });

  test('only the isolated native call surface may cross the keyguard', () {
    final manifest = File(
      'third_party/polycule_call_notifications/android/src/main/'
      'AndroidManifest.xml',
    ).readAsStringSync();
    final plugin = File(
      'third_party/polycule_call_notifications/android/src/main/kotlin/'
      'business/braid/polycule/callnotifications/'
      'PolyculeCallNotificationsPlugin.kt',
    ).readAsStringSync();
    final surface = File(
      'third_party/polycule_call_notifications/android/src/main/kotlin/'
      'business/braid/polycule/callnotifications/IncomingCallActivity.kt',
    ).readAsStringSync();

    expect(
      manifest,
      contains(
        'android:name="business.braid.polycule.callnotifications.'
        'IncomingCallActivity"',
      ),
    );
    expect(manifest, contains('android:exported="false"'));
    expect(manifest, contains('android:noHistory="true"'));
    expect(manifest, contains('android:showWhenLocked="true"'));
    expect(
      plugin,
      contains('Intent(context, IncomingCallActivity::class.java)'),
    );
    expect(surface, isNot(contains('FlutterActivity')));
    expect(surface, contains('FLAG_SECURE'));
  });
}
