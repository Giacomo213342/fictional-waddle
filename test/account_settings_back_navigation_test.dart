import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:polycule/src/pages/account_settings/account_settings_back_navigation.dart';
import 'package:polycule/src/widgets/responsive_layout.dart';

void main() {
  test('account settings root targets the active client room list', () {
    final uri = Uri.parse('/client/7/settings');
    expect(isAccountSettingsRoot(uri), isTrue);
    expect(accountSettingsBackTarget(uri), Uri.parse('/client/7/rooms'));
    expect(
      isAccountSettingsRoot(Uri.parse('/client/7/settings/emojis')),
      isFalse,
    );
  });

  testWidgets('native back from settings root opens the room list', (
    tester,
  ) async {
    final harness = _makeHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    expect(find.text('account settings'), findsOneWidget);
    expect(find.text('client splash'), findsNothing);
    expect(harness.settingsNavigatorKey.currentState, isNotNull);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('room list'), findsOneWidget);
    expect(find.text('client splash'), findsNothing);
  });

  testWidgets('nested settings pop before settings returns to rooms', (
    tester,
  ) async {
    final harness = _makeHarness(
      initialLocation: '/client/7/settings/details',
    );
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    expect(find.text('settings details'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('account settings'), findsOneWidget);
    expect(find.text('settings details'), findsNothing);
    expect(harness.canHandlePop, isTrue);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('room list'), findsOneWidget);
  });

  testWidgets('integrated arrow uses the same room-list destination', (
    tester,
  ) async {
    final harness = _makeHarness();
    addTearDown(harness.router.dispose);
    await tester.pumpWidget(harness.app);

    await tester.tap(find.text('integrated back'));
    await tester.pumpAndSettle();

    expect(find.text('room list'), findsOneWidget);
  });
}

class _Harness {
  _Harness({required this.router, required this.settingsNavigatorKey});

  final GoRouter router;
  final GlobalKey<NavigatorState> settingsNavigatorKey;
  bool? canHandlePop;

  Widget get app => MaterialApp.router(
        routerConfig: router,
        onNavigationNotification: (notification) {
          canHandlePop = notification.canHandlePop;
          return true;
        },
      );
}

_Harness _makeHarness({
  String initialLocation = '/client/7/settings',
}) {
  final branchNavigatorKey = GlobalKey<NavigatorState>();
  final settingsNavigatorKey = GlobalKey<NavigatorState>();
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: [
      ShellRoute(
        navigatorKey: branchNavigatorKey,
        builder: (context, state, child) => child,
        routes: [
          GoRoute(
            path: '/client/:client',
            builder: (context, state) => const Text('client splash'),
            routes: [
              GoRoute(
                path: 'rooms',
                builder: (context, state) => const Text('room list'),
              ),
            ],
          ),
          ShellRoute(
            navigatorKey: settingsNavigatorKey,
            builder: (context, state, child) => AccountSettingsBackHandler(
              uri: state.uri,
              nestedNavigatorKey: settingsNavigatorKey,
              child: ResponsiveLayout(
                uri: state.uri,
                main: const _SettingsRoot(),
                secondary: child,
              ),
            ),
            routes: [
              GoRoute(
                path: '/client/:client/settings',
                builder: (context, state) => const SizedBox.shrink(),
                routes: [
                  GoRoute(
                    path: 'details',
                    builder: (context, state) => const Text('settings details'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  return _Harness(
    router: router,
    settingsNavigatorKey: settingsNavigatorKey,
  );
}

class _SettingsRoot extends StatelessWidget {
  const _SettingsRoot();

  @override
  Widget build(BuildContext context) => Column(
        children: [
          const Text('account settings'),
          TextButton(
            onPressed: () => navigateBackFromAccountSettings(context),
            child: const Text('integrated back'),
          ),
        ],
      );
}
