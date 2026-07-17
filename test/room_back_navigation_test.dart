import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:polycule/src/pages/room/room_back_navigation.dart';
import 'package:polycule/src/widgets/responsive_sidebar_layout.dart';

void main() {
  group('room route classification', () {
    test('accepts only the room root', () {
      expect(
        isRoomRoot(Uri.parse('/client/1/rooms/%21room%3Aexample.org')),
        true,
      );
      expect(
        isRoomRoot(
          Uri.parse('/client/1/rooms/%21room%3Aexample.org#event'),
        ),
        true,
      );
      expect(
        isRoomRoot(Uri.parse('/client/1/rooms/%21room%3Aexample.org/details')),
        false,
      );
      expect(isRoomRoot(Uri.parse('/client/1/rooms')), false);
    });

    test('returns to the room list from a room root', () {
      expect(
        roomBackTarget(Uri.parse('/client/1/rooms/%21room%3Aexample.org')),
        Uri.parse('/client/1/rooms'),
      );
    });

    test('clears an event fragment before leaving the room', () {
      expect(
        roomBackTarget(
          Uri.parse('/client/1/rooms/%21room%3Aexample.org#event'),
        ),
        Uri.parse('/client/1/rooms/%21room%3Aexample.org'),
      );
    });
  });

  testWidgets('system back leaves the room', (tester) async {
    final harness = _makeProductionShellHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    expect(find.text('room'), findsOneWidget);
    expect(harness.roomNavigatorKey.currentState, isNotNull);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('system back still leaves after a root sheet scrim dismissal', (
    tester,
  ) async {
    final harness = _makeProductionShellHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    expect(harness.roomNavigatorKey.currentState, isNotNull);
    expect(harness.canHandlePop, isTrue);

    await tester.tap(find.text('open context menu'));
    await tester.pumpAndSettle();
    expect(find.text('context menu'), findsOneWidget);
    expect(harness.canHandlePop, isTrue);

    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('context menu'), findsNothing);
    expect(find.text('room'), findsOneWidget);
    expect(harness.roomNavigatorKey.currentState, isNotNull);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('system back closes a root sheet before leaving the room', (
    tester,
  ) async {
    final harness = _makeProductionShellHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    await tester.tap(find.text('open context menu'));
    await tester.pumpAndSettle();
    expect(find.text('context menu'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('context menu'), findsNothing);
    expect(find.text('room'), findsOneWidget);
    expect(harness.roomNavigatorKey.currentState, isNotNull);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('nested room page handles back before the room root', (
    tester,
  ) async {
    final harness = _makeProductionShellHarness(
      initialLocation: '/client/1/rooms/%21room%3Aexample.org/details',
    );
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    expect(find.text('details'), findsOneWidget);
    expect(harness.roomNavigatorKey.currentState, isNotNull);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('details'), findsNothing);
    expect(find.text('room'), findsOneWidget);
    expect(harness.router.state.uri.path, endsWith('!room:example.org'));
    expect(harness.canHandlePop, isTrue);
  });
}

class _ProductionShellHarness {
  _ProductionShellHarness({
    required this.router,
    required this.roomNavigatorKey,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> roomNavigatorKey;
  bool? canHandlePop;

  Widget get app => MaterialApp.router(
        routerConfig: router,
        onNavigationNotification: (notification) {
          canHandlePop = notification.canHandlePop;
          return true;
        },
      );
}

_ProductionShellHarness _makeProductionShellHarness({
  String initialLocation = '/client/1/rooms/%21room%3Aexample.org',
}) {
  final roomNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/client/:client/rooms',
        builder: (context, state) => const Scaffold(
          body: Text('room list'),
        ),
      ),
      ShellRoute(
        navigatorKey: roomNavigatorKey,
        builder: (context, state, child) => RoomShellBackHandler(
          uri: state.uri,
          nestedNavigatorKey: roomNavigatorKey,
          child: ResponsiveSidebarLayout(
            uri: state.uri,
            main: const _RoomHarnessPage(),
            sidebar: child,
          ),
        ),
        routes: [
          GoRoute(
            path: '/client/:client/rooms/:roomId',
            builder: (context, state) => const SizedBox.shrink(),
            routes: [
              GoRoute(
                path: 'details',
                builder: (context, state) => const Scaffold(
                  body: Text('details'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
  return _ProductionShellHarness(
    router: router,
    roomNavigatorKey: roomNavigatorKey,
  );
}

class _RoomHarnessPage extends StatelessWidget {
  const _RoomHarnessPage();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            const Text('room'),
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                useRootNavigator: true,
                builder: (context) => const SizedBox(
                  height: 200,
                  child: Text('context menu'),
                ),
              ),
              child: const Text('open context menu'),
            ),
          ],
        ),
      );
}
