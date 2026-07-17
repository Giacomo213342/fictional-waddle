import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

/// Returns the declarative route that precedes the current room state.
///
/// An event fragment is part of the room state, so it is cleared first. From
/// the plain room route, back returns to that client's room list.
Uri roomBackTarget(Uri uri) {
  if (uri.fragment.isNotEmpty) {
    return uri.replace(fragment: '');
  }

  final lastSeparator = uri.path.lastIndexOf('/');
  assert(lastSeparator > 0, 'A room route must have a parent route.');
  return uri.replace(
    path: uri.path.substring(0, lastSeparator),
    fragment: '',
  );
}

void navigateBackFromRoom(BuildContext context) {
  final uri = GoRouterState.of(context).uri;
  GoRouter.of(context).go(roomBackTarget(uri).toString());
}

/// Declares back handling on the actual `/rooms/:roomId` leaf route.
///
/// The visible room view is built by an ancestor shell and therefore cannot
/// register a pop entry on this route. Keeping this scope on the leaf lets the
/// nested navigator report ahead of time that Android back can be handled.
class RoomRouteBackScope extends StatelessWidget {
  const RoomRouteBackScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) navigateBackFromRoom(context);
      },
      child: child,
    );
  }
}
