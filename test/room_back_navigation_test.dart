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

  testWidgets('system back still leaves after a room sheet scrim dismissal', (
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
    expect(harness.branchNavigatorKey.currentState!.canPop(), isTrue);
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

  testWidgets('room back survives an action dialog opened from its sheet', (
    tester,
  ) async {
    final harness = _makeProductionShellHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    await tester.tap(find.text('open context menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('delete'));
    await tester.pumpAndSettle();
    expect(find.text('confirm delete'), findsOneWidget);
    expect(harness.branchNavigatorKey.currentState!.canPop(), isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('confirm delete'), findsNothing);
    expect(find.text('room'), findsOneWidget);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('room back survives a fullscreen route', (tester) async {
    final harness = _makeProductionShellHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    await tester.tap(find.text('open photo'));
    await tester.pumpAndSettle();
    expect(find.text('fullscreen photo'), findsOneWidget);
    expect(harness.branchNavigatorKey.currentState!.canPop(), isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('fullscreen photo'), findsNothing);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('system back closes a room sheet before leaving the room', (
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
    required this.branchNavigatorKey,
  });

  final GoRouter router;
  final GlobalKey<NavigatorState> roomNavigatorKey;
  final GlobalKey<NavigatorState> branchNavigatorKey;
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
  final branchNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        navigatorKey: branchNavigatorKey,
        builder: (context, state, child) => child,
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
      ),
    ],
  );
  return _ProductionShellHarness(
    router: router,
    roomNavigatorKey: roomNavigatorKey,
    branchNavigatorKey: branchNavigatorKey,
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
                useRootNavigator: false,
                builder: (sheetContext) => SizedBox(
                  height: 200,
                  child: Column(
                    children: [
                      const Text('context menu'),
                      TextButton(
                        onPressed: () {
                          Navigator.of(sheetContext).pop();
                          showDialog<void>(
                            context: context,
                            useRootNavigator: false,
                            builder: (context) => const AlertDialog(
                              title: Text('confirm delete'),
                            ),
                          );
                        },
                        child: const Text('delete'),
                      ),
                    ],
                  ),
                ),
              ),
              child: const Text('open context menu'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).push<void>(
                MaterialPageRoute(
                  fullscreenDialog: true,
                  builder: (context) => const Scaffold(
                    body: Text('fullscreen photo'),
                  ),
                ),
              ),
              child: const Text('open photo'),
            ),
          ],
        ),
      );
}
