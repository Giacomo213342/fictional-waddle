import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../pages/room_list/room_list.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';

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
    final identifier = ClientManager.extractClientIdentifierFromRoute(state);
    if (identifier == null) {
      return null;
    }
    final client = ClientManager.getClientByIdentifier(identifier);
    if (client != null && client.isLogged()) {
      return '/client/$identifier${RoomListPage.routeName}';
    }
    return null;
  }
}
