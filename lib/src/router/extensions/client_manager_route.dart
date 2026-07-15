import 'package:go_router/go_router.dart';

import '../../widgets/matrix/client_manager/client_tab_view.dart';
import '../../widgets/matrix/matrix_dialog_scope/matrix_dialog_scope.dart';

class ClientManagerRoute extends StatefulShellRoute {
  ClientManagerRoute({
    required super.branches,
    super.key,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.restorationScopeId,
  }) : super.indexedStack(
          builder: (context, state, shell) => MatrixDialogScope(
            child: ClientTabView(
              uri: state.uri,
              child: shell,
            ),
          ),
        );
}
