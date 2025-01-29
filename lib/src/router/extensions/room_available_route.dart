import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/room/room.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/room_scope.dart';
import 'requires_login_route.dart';

typedef RoomUnavailableBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  PublicRoomQueryFilter query,
  Set<String> via,
  String? action,
  String? eventId,
);

class RoomAvailableRoute extends RequiresLoginRoute {
  RoomAvailableRoute({
    required super.path,
    super.name,
    GoRouterWidgetBuilder? builder,
    RoomUnavailableBuilder? roomUnavailableBuilder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(
          builder: builder == null
              ? null
              : _roomInjectedBuilder(
                  builder,
                  roomUnavailableBuilder,
                ),
        );

  static GoRouterWidgetBuilder _roomInjectedBuilder(
    GoRouterWidgetBuilder builder,
    RoomUnavailableBuilder? roomUnavailableBuilder,
  ) =>
      (
        BuildContext context,
        GoRouterState state,
      ) {
        final identifier = ClientManager.extractClientIdentifierFromRoute(
          state,
        );
        if (identifier == null) {
          return const FatalErrorPage();
        }
        final client = ClientManager.getClientByIdentifier(identifier);
        if (client == null) {
          return const FatalErrorPage();
        }
        final parameter = state.pathParameters[RoomPage.pathParameter];
        if (parameter == null) {
          return const FatalErrorPage();
        }
        final roomId = Uri.decodeComponent(parameter);
        final room =
            client.getRoomById(roomId) ?? client.getRoomByAlias(roomId);

        if (room == null || room.isSpace) {
          final fragment = state.uri.fragment;
          final eventId = Uri.decodeComponent(
            fragment.isEmpty ? state.uri.pathSegments[1] : fragment,
          );

          return roomUnavailableBuilder?.call(
                context,
                state,
                PublicRoomQueryFilter(
                  genericSearchTerm: roomId,
                ),
                state.uri.queryParametersAll['via']
                        ?.map((d) => Uri.decodeComponent(d))
                        .toSet() ??
                    {},
                state.uri.queryParameters['action'],
                eventId,
              ) ??
              const FatalErrorPage();
        }

        return RoomScope(
          room: room,
          child: builder.call(context, state),
        );
      };
}
