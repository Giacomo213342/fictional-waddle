import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../pages/splash_screen/splash_screen.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import 'go_router_path_extension.dart';

class RequiresLoginRoute extends GoRoute {
  RequiresLoginRoute({
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
      return context.clientifyLocation(SplashPage.routeName);
    }
    final client = ClientManager.getClientByIdentifier(identifier);
    if (client == null || !client.isLogged()) {
      return context.clientifyLocation(SplashPage.routeName);
    }
    return null;
  }
}
