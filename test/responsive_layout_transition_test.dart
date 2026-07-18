import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/widgets/responsive_layout.dart';

void main() {
  testWidgets('compact room push and pop are fast, mirrored, and state-safe', (
    tester,
  ) async {
    final showDetail = ValueNotifier(false);
    addTearDown(showDetail.dispose);
    var mainInitializations = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 800,
          child: ValueListenableBuilder<bool>(
            valueListenable: showDetail,
            builder: (context, visible, _) => CompactDetailTransition(
              showDetail: visible,
              main: _StateProbe(
                label: 'room list',
                onInit: () => mainInitializations++,
              ),
              detail: const Text('room'),
            ),
          ),
        ),
      ),
    );

    expect(mainInitializations, 1);
    expect(_mainTranslation(tester), Offset.zero);
    expect(
      find.byKey(CompactDetailTransition.detailLayerKey),
      findsNothing,
    );

    showDetail.value = true;
    await tester.pump();
    expect(
      find.byKey(CompactDetailTransition.detailLayerKey),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 60));
    expect(_mainTranslation(tester).dx, inExclusiveRange(-.1, 0));
    expect(_detailTranslation(tester).dx, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_mainTranslation(tester).dx, closeTo(-.1, .001));
    expect(_detailTranslation(tester), Offset.zero);
    expect(mainInitializations, 1);

    showDetail.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(_mainTranslation(tester).dx, inExclusiveRange(-.1, 0));
    expect(_detailTranslation(tester).dx, inExclusiveRange(0, 1));

    await tester.pumpAndSettle();
    expect(_mainTranslation(tester), Offset.zero);
    expect(
      find.byKey(CompactDetailTransition.detailLayerKey),
      findsNothing,
    );
    expect(
      find.byKey(
        CompactDetailTransition.detailLayerKey,
        skipOffstage: false,
      ),
      findsOneWidget,
    );
    expect(mainInitializations, 1);
  });

  testWidgets('switching rooms replaces content without replaying transition', (
    tester,
  ) async {
    final room = ValueNotifier('room A');
    addTearDown(room.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 400,
          height: 800,
          child: ValueListenableBuilder<String>(
            valueListenable: room,
            builder: (context, value, _) => CompactDetailTransition(
              showDetail: true,
              main: const Text('room list'),
              detail: Text(value, key: ValueKey(value)),
            ),
          ),
        ),
      ),
    );

    expect(_detailTranslation(tester), Offset.zero);
    expect(find.text('room A'), findsOneWidget);

    room.value = 'room B';
    await tester.pump();

    expect(find.text('room A'), findsNothing);
    expect(find.text('room B'), findsOneWidget);
    expect(_detailTranslation(tester), Offset.zero);
  });

  testWidgets('reduced motion switches immediately', (tester) async {
    final showDetail = ValueNotifier(false);
    addTearDown(showDetail.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SizedBox(
            width: 400,
            height: 800,
            child: ValueListenableBuilder<bool>(
              valueListenable: showDetail,
              builder: (context, visible, _) => CompactDetailTransition(
                showDetail: visible,
                main: const Text('room list'),
                detail: const Text('room'),
              ),
            ),
          ),
        ),
      ),
    );

    showDetail.value = true;
    await tester.pump();

    expect(_mainTranslation(tester).dx, closeTo(-.1, .001));
    expect(_detailTranslation(tester), Offset.zero);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}

Offset _mainTranslation(WidgetTester tester) => tester
    .widget<FractionalTranslation>(
      find.byKey(CompactDetailTransition.mainLayerKey),
    )
    .translation;

Offset _detailTranslation(WidgetTester tester) => tester
    .widget<FractionalTranslation>(
      find.byKey(CompactDetailTransition.detailLayerKey),
    )
    .translation;

class _StateProbe extends StatefulWidget {
  const _StateProbe({required this.label, required this.onInit});

  final String label;
  final VoidCallback onInit;

  @override
  State<_StateProbe> createState() => _StateProbeState();
}

class _StateProbeState extends State<_StateProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => Text(widget.label);
}
