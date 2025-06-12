import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../widgets/matrix/client_manager/login_state_listener.dart';

class LoginStateRedirectRoute extends ShellRoute {
  LoginStateRedirectRoute({
    required super.routes,
    super.navigatorKey,
    super.observers,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.restorationScopeId,
  }) : super(builder: _loginStateBuilder);

  static Widget _loginStateBuilder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) =>
      LoginStateListener(child: child);
}
