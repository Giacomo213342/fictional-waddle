import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../room_list/room_list.dart';

bool isAccountSettingsRoot(Uri uri) {
  final segments = uri.pathSegments;
  return segments.length == 3 &&
      segments[0] == 'client' &&
      segments[1].isNotEmpty &&
      segments[2] == 'settings';
}

Uri accountSettingsBackTarget(Uri uri) {
  final segments = uri.pathSegments;
  assert(
    segments.length >= 3 && segments[0] == 'client' && segments[1].isNotEmpty,
    'Account settings must be inside a client route.',
  );
  return Uri(
    path: '/${[
      segments[0],
      segments[1],
      RoomListPage.routeName.substring(1),
    ].join('/')}',
  );
}

void navigateBackFromAccountSettings(BuildContext context) {
  final uri = GoRouterState.of(context).uri;
  GoRouter.of(context).go(accountSettingsBackTarget(uri).toString());
}

/// Keeps native back inside the active client branch.
///
/// Account settings is reached with `go`, so popping its leaf route exposes
/// the client splash route rather than meaningful history. At the settings
/// root, back therefore has an explicit room-list destination. Nested settings
/// pages still pop their own Navigator first.
class AccountSettingsBackHandler extends StatelessWidget {
  const AccountSettingsBackHandler({
    super.key,
    required this.uri,
    required this.nestedNavigatorKey,
    required this.child,
  });

  final Uri uri;
  final GlobalKey<NavigatorState> nestedNavigatorKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (isAccountSettingsRoot(uri)) {
      return PopScope<void>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            GoRouter.of(context).go(accountSettingsBackTarget(uri).toString());
          }
        },
        child: NotificationListener<NavigationNotification>(
          // The compact layout keeps the empty nested Navigator offstage. Its
          // false notification must not unregister Android back handling.
          onNotification: (_) => true,
          child: child,
        ),
      );
    }

    return NavigatorPopHandler<Object?>(
      onPopWithResult: (result) async {
        await nestedNavigatorKey.currentState?.maybePop(result);
      },
      child: child,
    );
  }
}
