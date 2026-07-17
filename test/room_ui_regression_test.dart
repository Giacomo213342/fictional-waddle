import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/pages/room/components/event/components/attachment_toolbar.dart';
import 'package:polycule/src/pages/room_list/components/room_search_bar.dart';
import 'package:polycule/src/widgets/responsive_sidebar_layout.dart';

void main() {
  group('fullscreen image bounds', () {
    const viewport = Size.square(400);
    const landscapeImage = Size(400, 100);

    test('preserves a valid position inside the black-band range', () {
      final input = Matrix4.diagonal3Values(2, 2, 1)
        ..setTranslationRaw(-200, -250, 0);

      final first = constrainFittedImageTransform(
        input,
        viewport,
        landscapeImage,
      );
      final second = constrainFittedImageTransform(
        first,
        viewport,
        landscapeImage,
      );

      expect(first.getTranslation().y, -250);
      expect(second.getTranslation().y, -250);
    });

    test('clamps only to the nearest valid black-band edge', () {
      final input = Matrix4.diagonal3Values(2, 2, 1)
        ..setTranslationRaw(-200, 20, 0);
      final result = constrainFittedImageTransform(
        input,
        viewport,
        landscapeImage,
      );

      expect(result.getTranslation().y, -100);
    });

    test('keeps fitted scale centered and oversized axes covered', () {
      final fitted = Matrix4.identity()..setTranslationRaw(30, -20, 0);
      final fittedResult = constrainFittedImageTransform(
        fitted,
        viewport,
        landscapeImage,
      );
      expect(fittedResult.getTranslation().x, 0);
      expect(fittedResult.getTranslation().y, 0);

      final oversized = Matrix4.diagonal3Values(2, 2, 1)
        ..setTranslationRaw(100, -500, 0);
      final oversizedResult = constrainFittedImageTransform(
        oversized,
        viewport,
        const Size.square(400),
      );
      expect(oversizedResult.getTranslation().x, 0);
      expect(oversizedResult.getTranslation().y, -400);
    });

    testWidgets('a new gesture continues from the preserved band position', (
      tester,
    ) async {
      final controller = TransformationController(
        Matrix4.diagonal3Values(2, 2, 1)..setTranslationRaw(-200, -250, 0),
      );
      addTearDown(controller.dispose);

      void constrain() {
        final current = controller.value;
        final constrained = constrainFittedImageTransform(
          current,
          viewport,
          landscapeImage,
        );
        final before = current.getTranslation();
        final after = constrained.getTranslation();
        if (before.x != after.x || before.y != after.y) {
          controller.value = constrained;
        }
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: SizedBox.square(
              dimension: 400,
              child: FittedImageInteractiveViewer(
                transformationController: controller,
                onInteractionUpdate: (_) => constrain(),
                onInteractionEnd: (_) => constrain(),
                child: Center(
                  child: SizedBox.fromSize(size: landscapeImage),
                ),
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(FittedImageInteractiveViewer)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveBy(const Offset(0, 10));
      await tester.pump();

      expect(controller.value.getTranslation().y, closeTo(-240, 0.01));
      await gesture.up();
    });
  });

  testWidgets('collapsed home search is a launcher, not a text field', (
    tester,
  ) async {
    final controller = SearchController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SearchAnchor(
            searchController: controller,
            builder: (context, _) => SearchViewLauncher(
              label: 'Command, user, room name, or MXID',
              onPressed: controller.openView,
              accountButton: const SizedBox.shrink(),
            ),
            suggestionsBuilder: (context, controller) => const [],
          ),
        ),
      ),
    );

    expect(find.byType(EditableText), findsNothing);
    await tester.tap(find.text('Command, user, room name, or MXID'));
    await tester.pumpAndSettle();
    expect(find.byType(EditableText), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'room');
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.byType(EditableText), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('pinch focal matrix uses the viewer top-left origin', (
    tester,
  ) async {
    final controller = TransformationController();
    addTearDown(controller.dispose);
    const markerKey = Key('pinch-marker');
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 400,
            child: FittedImageInteractiveViewer(
              transformationController: controller,
              onInteractionUpdate: (_) {},
              onInteractionEnd: (_) {},
              child: const Stack(
                children: [
                  Positioned(
                    left: 294,
                    top: 194,
                    child: SizedBox.square(key: markerKey, dimension: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final originalMarker = tester.getCenter(find.byKey(markerKey));
    // InteractiveViewer produces this matrix for a 2x pinch around the
    // marker's local position (300, 200). Applying it around any additional
    // alignment origin would move the marker away from the fingers.
    controller.value = Matrix4.diagonal3Values(2, 2, 1)
      ..setTranslationRaw(-300, -200, 0);
    await tester.pump();

    expect(controller.value.getMaxScaleOnAxis(), greaterThan(1));
    final movedMarker = tester.getCenter(find.byKey(markerKey));
    expect((movedMarker - originalMarker).distance, lessThan(0.01));
  });

  testWidgets('switching rooms never retains the previous room for a fade', (
    tester,
  ) async {
    final room = ValueNotifier<String>('room A');
    addTearDown(room.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<String>(
          valueListenable: room,
          builder: (context, value, _) => ResponsiveSidebarLayout(
            uri: Uri.parse('/client/1/rooms/$value'),
            main: Text(value, key: ValueKey(value)),
            sidebar: const SizedBox.shrink(),
          ),
        ),
      ),
    );
    expect(find.text('room A'), findsOneWidget);

    room.value = 'room B';
    await tester.pump();

    expect(find.text('room A'), findsNothing);
    expect(find.text('room B'), findsOneWidget);
  });
}
