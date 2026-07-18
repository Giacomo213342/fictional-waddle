import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../pages/account_settings/account_settings_back_navigation.dart';
import '../../pages/room/room_back_navigation.dart';
import '../../widgets/matrix/call/call_overlay_host.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_manager/client_tab_view.dart';
import '../../widgets/matrix/matrix_dialog_scope/matrix_dialog_scope.dart';

class ClientManagerRoute extends StatefulShellRoute {
  ClientManagerRoute({
    required List<StatefulShellBranch> branches,
    super.key,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.redirect,
    super.restorationScopeId,
  }) : super(
          branches: branches,
          navigatorContainerBuilder: _activeBranchContainer,
          builder: (context, state, shell) => ActiveClientBackNotificationGuard(
            uri: state.uri,
            child: CallOverlayHost(
              coordinator: ClientManager.of(context).callCoordinator,
              activeNavigatorKey: branches[shell.currentIndex].navigatorKey,
              child: MatrixDialogScope(
                child: ClientTabView(
                  uri: state.uri,
                  child: shell,
                ),
              ),
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

/// Prevents the active branch Navigator from overwriting an explicit back
/// owner mounted inside its current route.
///
/// Removing a fullscreen call route and popping the last nested settings page
/// both make the branch Navigator publish `canHandlePop: false`. At a room or
/// account-settings root that value describes only the Navigator stack: the
/// visible route still owns back through a [PopScope]. Let the positive scope
/// notification bubble and discard only the stale negative parent value.
class ActiveClientBackNotificationGuard extends StatelessWidget {
  const ActiveClientBackNotificationGuard({
    super.key,
    required this.uri,
    required this.child,
  });

  final Uri uri;
  final Widget child;

  bool get _routeOwnsBack => isRoomRoot(uri) || isAccountSettingsRoot(uri);

  @override
  Widget build(BuildContext context) =>
      NotificationListener<NavigationNotification>(
        onNotification: (notification) =>
            _routeOwnsBack && !notification.canHandlePop,
        child: child,
      );
}
