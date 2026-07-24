import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/widgets/android_predictive_back_scope.dart';

void main() {
  testWidgets('hardware back keeps the declarative fallback', (tester) async {
    var backCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AndroidPredictiveBackScope(
          onBack: () => backCount++,
          child: const Scaffold(body: Text('page')),
        ),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(backCount, 1);
  });

  test('Android manifest and theme opt in to predictive back', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    final theme = File(
      'lib/src/theme/theme_builder.dart',
    ).readAsStringSync();
    final rooms = File(
      'lib/src/pages/room/room_back_navigation.dart',
    ).readAsStringSync();

    expect(manifest, contains('android:enableOnBackInvokedCallback="true"'));
    expect(theme, contains('PredictiveBackPageTransitionsBuilder()'));
    expect(rooms, contains('AndroidPredictiveBackScope'));
  });
}
