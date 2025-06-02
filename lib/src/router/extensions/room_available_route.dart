import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/room/room.dart';
import '../../widgets/matrix/scopes/room_scope.dart';
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
    required super.client,
    required super.path,
    super.name,
    required GoRouterWidgetBuilder builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(
          builder: (
            BuildContext context,
            GoRouterState state,
          ) {
            final parameter = state.pathParameters[RoomPage.pathParameter];
            if (parameter == null) {
              return const FatalErrorPage();
            }
            final roomId = Uri.decodeComponent(parameter);
            final room =
                client.getRoomById(roomId) ?? client.getRoomByAlias(roomId);

            if (room == null || room.isSpace) {
              return const FatalErrorPage();
            }

            return RoomScope(
              room: room,
              child: builder.call(context, state),
            );
          },
        );
}
