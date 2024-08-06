import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/room/room.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import 'requires_login_route.dart';

typedef RoomAvailableBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Room room,
);

typedef RoomUnavailableBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  PublicRoomQueryFilter query,
  Set<String> via,
  String? action,
);

class RoomAvailableRoute extends RequiresLoginRoute {
  RoomAvailableRoute({
    required super.path,
    super.name,
    RoomAvailableBuilder? builder,
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
    RoomAvailableBuilder builder,
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

        if (room == null) {
          return roomUnavailableBuilder?.call(
                context,
                state,
                PublicRoomQueryFilter(
                  genericSearchTerm: roomId,
                ),
                state.uri.queryParametersAll['via']?.toSet() ?? {},
                state.uri.queryParameters['action'],
              ) ??
              const FatalErrorPage();
        }

        return builder.call(context, state, room);
      };
}
