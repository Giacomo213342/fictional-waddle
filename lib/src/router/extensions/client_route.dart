import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class ClientRoute extends GoRoute {
  ClientRoute({
    required this.client,
    required super.path,
    super.builder,
    super.caseSensitive,
    super.name,
    super.onExit,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.routes,
  });

  final Client client;
}

class ClientShellRoute extends ShellRoute {
  ClientShellRoute({
    required this.client,
    required super.routes,
    super.builder,
    super.navigatorKey,
    super.observers,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.restorationScopeId,
  });

  final Client client;
}
