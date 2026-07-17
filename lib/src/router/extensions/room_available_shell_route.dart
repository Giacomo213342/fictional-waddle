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
          builder: (context, state, child) {
            // check whether we have an event deep link
            String? eventId;
            final fragment = state.uri.fragment;
            if (fragment.isNotEmpty) {
              eventId = Uri.decodeComponent(fragment);
            } else if (state.uri.pathSegments.length >= 2) {
              eventId = Uri.decodeComponent(
                state.uri.pathSegments[1],
              );
            }

            final parameter = state.pathParameters[RoomPage.pathParameter]!;

            final roomId = Uri.decodeComponent(parameter);
            final room =
                client.getRoomById(roomId) ?? client.getRoomByAlias(roomId);

            // handle public rooms / unknown rooms
            if (room == null) {
              final identifier = MatrixIdentifierStringExtensionResults(
                primaryIdentifier: roomId,
                secondaryIdentifier: eventId,
                via: state.uri.queryParametersAll['via']
                        ?.map((d) => Uri.decodeComponent(d))
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

            // handle spaces
            if (room.isSpace) {
              return RoomShellBackHandler(
                uri: state.uri,
                nestedNavigatorKey: navigatorKey,
                child: ResponsiveSidebarLayout(
                  uri: state.uri,
                  main: RoomScope(
                    room: room,
                    child: spaceBuilder?.call(context, state) ??
                        const FatalErrorPage(),
                  ),
                  sidebar: child,
                ),
              );
            }
            // handle regular rooms
            else {
              return RoomShellBackHandler(
                uri: state.uri,
                nestedNavigatorKey: navigatorKey,
                child: ResponsiveSidebarLayout(
                  uri: state.uri,
                  main: RoomScope(
                    room: room,
                    child: builder.call(context, state),
                  ),
                  sidebar: child,
                ),
              );
            }
          },
        );
}
