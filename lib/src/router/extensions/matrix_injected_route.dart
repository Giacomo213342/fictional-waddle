import 'package:go_router/go_router.dart';

import '../../widgets/matrix/client_manager.dart';

class MatrixInjectedRoute extends ShellRoute {
  MatrixInjectedRoute({
    required super.routes,
    super.observers,
    super.navigatorKey,
    super.parentNavigatorKey,
    super.restorationScopeId,
  }) : super(
          builder: ClientManagerWidget.routeBuilder,
        );
}
