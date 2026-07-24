import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/widgets/android_predictive_back_scope.dart';

void main() {
  testWidgets('a local dialog leaves its parent back handler active', (
    tester,
  ) async {
    var parentBackCount = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: AndroidPredictiveBackScope(
          onBack: () => parentBackCount++,
          child: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog<void>(
                    context: context,
                    useRootNavigator: false,
                    builder: (context) => AlertDialog(
                      title: const Text('Create poll'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('m.poll'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('m.poll'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Create poll'), findsNothing);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(parentBackCount, 1);
  });

  test('poll selection waits for dropdown and uses the room navigator', () {
    final source = File(
      'lib/src/pages/room/components/compose/msgtype_dropdown.dart',
    ).readAsStringSync();

    expect(source, contains('await WidgetsBinding.instance.endOfFrame'));
    expect(source, contains('useRootNavigator: false'));
    expect(
      'compose.setSendMsgType(MessageTypes.Text)'.allMatches(source),
      hasLength(greaterThanOrEqualTo(2)),
    );
  });
}
