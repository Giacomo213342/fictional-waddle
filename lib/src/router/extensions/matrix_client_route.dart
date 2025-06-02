import '../../widgets/matrix/scopes/client_scope.dart';
import 'client_route.dart';

class MatrixClientRoute extends ClientShellRoute {
  MatrixClientRoute({
    required super.client,
    required super.routes,
    super.parentNavigatorKey,
    super.restorationScopeId,
  }) : super(
          builder: (context, state, child) => ClientScope(
            client: client,
            child: child,
          ),
        );
}
