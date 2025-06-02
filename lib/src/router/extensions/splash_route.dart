import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../pages/room_list/room_list.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import 'go_router_path_extension.dart';

class SplashRoute extends GoRoute {
  SplashRoute({
    required super.path,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(redirect: _splashScreenRedirect);

  static String? _splashScreenRedirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final identifier = state.clientIdentifier;
    if (identifier == null) {
      return null;
    }
    if (state.path != '/client/$identifier/') {
      return null;
    }
    final client = ClientManager.of(context).getClientByIdentifier(identifier);
    if (client != null && client.isLogged()) {
      return '/client/$identifier${RoomListPage.routeName}';
    }
    return null;
  }
}
