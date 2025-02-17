import 'package:go_router/go_router.dart';

import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_manager/client_store.dart';
import '../../widgets/matrix/client_manager/client_tab_view.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import 'go_router_path_extension.dart';

class MatrixInjectedRoute extends ShellRoute {
  MatrixInjectedRoute({
    required super.routes,
    super.observers,
    super.navigatorKey,
    super.parentNavigatorKey,
    super.restorationScopeId,
  }) : super(
          builder: (context, state, child) {
            final manager = ClientManager.of(context);
            if (manager.store.activeClients.value.isEmpty) {
              return child;
            }
            final identifier = state.clientIdentifier ??
                manager.store.activeClients.value.first.clientName
                    .clientIdentifier;
            final client = manager.getClientByIdentifier(identifier);
            if (client == null) {
              return child;
            }
            return ClientScope(
              client: client,
              child: ClientTabView(
                child: child,
              ),
            );
          },
        );
}
