import 'package:flutter/widgets.dart';

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
  }) : super(
          navigatorContainerBuilder: _activeBranchContainer,
          builder: (context, state, shell) => MatrixDialogScope(
            child: ClientTabView(
              uri: state.uri,
              child: shell,
            ),
          ),
        );

  /// Keeps the state of every account branch while allowing only the active
  /// Navigator to report whether Android back can be handled.
  ///
  /// Offstage Navigators still dispatch [NavigationNotification]s. Letting
  /// those notifications escape an IndexedStack means an inactive branch can
  /// overwrite the active branch's `canHandlePop` value and make Android
  /// unregister Flutter's back callback. The platform then closes the Activity
  /// without ever asking GoRouter to pop the room.
  static Widget _activeBranchContainer(
    BuildContext context,
    StatefulNavigationShell shell,
    List<Widget> children,
  ) {
    return IndexedStack(
      index: shell.currentIndex,
      children: List.generate(children.length, (index) {
        final active = index == shell.currentIndex;
        return Offstage(
          offstage: !active,
          child: TickerMode(
            enabled: active,
            child: active
                ? children[index]
                : NotificationListener<NavigationNotification>(
                    onNotification: (_) => true,
                    child: children[index],
                  ),
          ),
        );
      }),
    );
  }
}
