import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/room/room.dart';
import '../../pages/room/room_back_navigation.dart';
import '../../widgets/matrix/scopes/matrix_identifier_scope.dart';
import '../../widgets/matrix/scopes/room_scope.dart';
import '../../widgets/responsive_sidebar_layout.dart';
import 'client_route.dart';

class RoomAvailableShellRoute extends ClientShellRoute {
  RoomAvailableShellRoute({
    required super.client,
    required GlobalKey<NavigatorState> navigatorKey,
    required GoRouterWidgetBuilder builder,
    GoRouterWidgetBuilder? spaceBuilder,
    GoRouterWidgetBuilder? roomUnavailableBuilder,
    super.observers,
    required super.routes,
    super.parentNavigatorKey,
    super.restorationScopeId,
  }) : super(
          navigatorKey: navigatorKey,
          // This shell used to be pushed above the room-list placeholder with
          // the platform page transition. During that transition the full
          // screen "Polycule - yes, another Matrix client" placeholder was
          // necessarily exposed. Enter the already-cached room immediately;
          // the timeline itself owns the lightweight history reveal.
          pageBuilder: (context, state, child) => NoTransitionPage<void>(
            key: state.pageKey,
            child: _buildRoomShell(
              context: context,
              state: state,
              child: child,
              client: client,
              navigatorKey: navigatorKey,
              builder: builder,
              spaceBuilder: spaceBuilder,
              roomUnavailableBuilder: roomUnavailableBuilder,
            ),
          ),
        );

  static Widget _buildRoomShell({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
    required Client client,
    required GlobalKey<NavigatorState> navigatorKey,
    required GoRouterWidgetBuilder builder,
    required GoRouterWidgetBuilder? spaceBuilder,
    required GoRouterWidgetBuilder? roomUnavailableBuilder,
  }) {
    String? eventId;
    final fragment = state.uri.fragment;
    if (fragment.isNotEmpty) {
      eventId = Uri.decodeComponent(fragment);
    } else if (state.uri.pathSegments.length >= 2) {
      eventId = Uri.decodeComponent(state.uri.pathSegments[1]);
    }

    final parameter = state.pathParameters[RoomPage.pathParameter]!;
    final roomId = Uri.decodeComponent(parameter);
    final room = client.getRoomById(roomId) ?? client.getRoomByAlias(roomId);

    if (room == null) {
      final identifier = MatrixIdentifierStringExtensionResults(
        primaryIdentifier: roomId,
        secondaryIdentifier: eventId,
        via: state.uri.queryParametersAll['via']
                ?.map((domain) => Uri.decodeComponent(domain))
                .toSet() ??
            {},
        action: state.uri.queryParameters['action'],
      );
      return RoomShellBackHandler(
        uri: state.uri,
        nestedNavigatorKey: navigatorKey,
        child: MatrixIdentifierScope(
          identifier: identifier,
          child: roomUnavailableBuilder?.call(context, state) ??
              const FatalErrorPage(),
        ),
      );
    }

    final roomContent = room.isSpace
        ? spaceBuilder?.call(context, state) ?? const FatalErrorPage()
        : builder.call(context, state);
    return RoomShellBackHandler(
      uri: state.uri,
      nestedNavigatorKey: navigatorKey,
      child: ResponsiveSidebarLayout(
        uri: state.uri,
        main: RoomScope(
          room: room,
          child: KeyedSubtree(
            key: ValueKey((room.id, state.uri.fragment)),
            child: roomContent,
          ),
        ),
        sidebar: child,
      ),
    );
  }
}
