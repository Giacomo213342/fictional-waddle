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

/// Whether [uri] identifies the room itself rather than a nested room page.
///
/// Room ids are URI-encoded and therefore occupy exactly one path segment.
/// Query parameters and an event fragment do not make this a nested page.
bool isRoomRoot(Uri uri) {
  final segments = uri.pathSegments;
  return segments.length == 4 &&
      segments[0] == 'client' &&
      segments[1].isNotEmpty &&
      segments[2] == 'rooms' &&
      segments[3].isNotEmpty;
}

void navigateBackFromRoom(BuildContext context) {
  final uri = GoRouterState.of(context).uri;
  GoRouter.of(context).go(roomBackTarget(uri).toString());
}

/// Declares back handling on the shell route that actually displays a room.
///
/// On compact layouts the nested `/rooms/:roomId` navigator is not mounted:
/// the responsive layout displays the shell's main widget directly. This scope
/// must therefore wrap that shell widget, not the nested leaf placeholder.
class RoomRouteBackScope extends StatelessWidget {
  const RoomRouteBackScope({
    super.key,
    required this.uri,
    required this.child,
  });

  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return PopScope<void>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          GoRouter.of(context).go(roomBackTarget(uri).toString());
        }
      },
      child: child,
    );
  }
}

/// Routes system back to the Navigator that is present for the current room
/// layout.
///
/// The base room and its nested pages are intentionally displayed by different
/// Navigators on compact screens. Keeping this choice in one widget prevents
/// an invisible Navigator from becoming the owner of Android back again.
class RoomShellBackHandler extends StatelessWidget {
  const RoomShellBackHandler({
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
    if (isRoomRoot(uri)) {
      return RoomRouteBackScope(uri: uri, child: child);
    }

    return NavigatorPopHandler<Object?>(
      onPopWithResult: (result) async {
        await nestedNavigatorKey.currentState?.maybePop(result);
      },
      child: child,
    );
  }
}
