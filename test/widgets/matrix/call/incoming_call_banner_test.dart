import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/widgets/matrix/call/call_overlay_host.dart';

void main() {
  testWidgets('opens, answers, and declines from compact incoming banner',
      (tester) async {
    var opened = 0;
    var answered = 0;
    var declined = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: IncomingCallBanner(
            callerName: 'Alice',
            video: false,
            onOpen: () => opened++,
            onAnswer: () => answered++,
            onDecline: () => declined++,
          ),
        ),
      ),
    );

    expect(find.text('Alice is calling you!'), findsOneWidget);

    await tester.tap(find.text('Alice is calling you!'));
    await tester.tap(find.byTooltip('Answer'));
    await tester.tap(find.byTooltip('Decline'));

    expect(opened, 1);
    expect(answered, 1);
    expect(declined, 1);
  });
}
