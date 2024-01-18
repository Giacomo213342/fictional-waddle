import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/splash_screen/splash_screen.dart';
import '../../widgets/matrix/client_manager.dart';

class MustBeLoggedOutRoute extends GoRoute {
  MustBeLoggedOutRoute({
    required super.path,
    super.name,
    super.builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(redirect: _splashScreenRedirect);

  static FutureOr<String?> _splashScreenRedirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final client = ClientManager.activeClient;
    final loginState = client?.onLoginStateChanged.value;
    if (loginState != LoginState.loggedOut) {
      return SplashPage.routeName;
    }
    return null;
  }
}
