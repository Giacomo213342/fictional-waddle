import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:polycule/src/pages/room/room_back_navigation.dart';

void main() {
  group('room route classification', () {
    test('accepts only the room root', () {
      expect(isRoomRoot(Uri.parse('/client/1/rooms/%21room%3Aexample.org')), true);
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
    final router = _makeRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    expect(find.text('room'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('system back still leaves after an overlay is dismissed', (
    tester,
  ) async {
    final router = _makeRouter();
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    await tester.tap(find.text('open overlay'));
    await tester.pumpAndSettle();
    expect(find.text('overlay'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('overlay'), findsNothing);
    expect(find.text('room'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('room list'), findsOneWidget);
  });
}

GoRouter _makeRouter() => GoRouter(
      initialLocation: '/client/1/rooms/%21room%3Aexample.org',
      routes: [
        GoRoute(
          path: '/client/:client/rooms',
          builder: (context, state) => const Scaffold(
            body: Text('room list'),
          ),
          routes: [
            GoRoute(
              path: ':roomId',
              builder: (context, state) => RoomShellBackHandler(
                uri: state.uri,
                nestedNavigatorKey: GlobalKey<NavigatorState>(),
                child: Scaffold(
                  body: Column(
                    children: [
                      const Text('room'),
                      TextButton(
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (context) => const AlertDialog(
                            content: Text('overlay'),
                          ),
                        ),
                        child: const Text('open overlay'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
