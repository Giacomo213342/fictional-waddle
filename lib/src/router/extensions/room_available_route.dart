import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/room/room.dart';
import '../../widgets/matrix/client_manager.dart';
import 'requires_login_route.dart';

typedef RoomAvailableBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Room room,
);

class RoomAvailableRoute extends RequiresLoginRoute {
  RoomAvailableRoute({
    required super.path,
    super.name,
    RoomAvailableBuilder? builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(
          builder: builder == null ? null : _roomInjectedBuilder(builder),
        );

  static GoRouterWidgetBuilder _roomInjectedBuilder(
    RoomAvailableBuilder builder,
  ) =>
      (
        BuildContext context,
        GoRouterState state,
      ) {
        final isInitialized = ClientManager.activeClients.isNotEmpty;
        if (!isInitialized) {
          return const FatalErrorPage();
        }
        final parameter = state.pathParameters['client'];
        if (parameter == null) {
          return const FatalErrorPage();
        }
        final identifier = int.tryParse(parameter);
        if (identifier == null) {
          return const FatalErrorPage();
        }
        final client = ClientManager.getClientByIdentifier(identifier);
        if (client == null) {
          return const FatalErrorPage();
        }
        final roomId = state.pathParameters[RoomPage.pathParameter];
        if (roomId == null) {
          return const FatalErrorPage();
        }
        final room = client.getRoomById(roomId);
        if (room == null) {
          return const FatalErrorPage();
        }

        return builder.call(context, state, room);
      };
}
