import 'package:go_router/go_router.dart';

import '../../pages/splash_screen/splash_screen.dart';
import 'client_route.dart';
import 'go_router_path_extension.dart';

class MustBeLoggedOutRoute extends ClientRoute {
  MustBeLoggedOutRoute({
    required super.client,
    required super.path,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(
          redirect: (context, state) {
            if (client.isLogged()) {
              return context.clientifyLocation(SplashPage.routeName);
            }
            return null;
          },
        );
}
