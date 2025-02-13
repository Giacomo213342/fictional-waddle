import 'package:flutter/material.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:go_router/go_router.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../scopes/client_scope.dart';
import '../client_manager.dart';
import 'settings_button.dart';
import 'tab.dart';

class ClientTabBar extends StatelessWidget implements PreferredSizeWidget {
  const ClientTabBar(
    this.manager, {
    super.key,
    this.position = VerticalDirection.down,
  });

  final ClientManager manager;
  final VerticalDirection position;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, visible) {
        return SafeArea(
          top: !visible && position == VerticalDirection.up,
          bottom: false,
          left: false,
          right: false,
          maintainBottomViewPadding: false,
          child: AnimatedSize(
            alignment: Alignment.bottomCenter,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: SizedBox(
              height: visible ? 0 : 48,
              child: ClipRect(
                child: Semantics(
                  hint: AppLocalizations.of(context).regionAccountSwitcher,
                  child: ListView.builder(
                    itemCount: ClientManager.activeClients.length + 3,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return SizedBox.square(
                          dimension: 48,
                          child: BackButton(
                            onPressed: () {
                              if (Navigator.of(context).canPop()) {
                                return Navigator.of(context).pop();
                              }
                              final path = GoRouterState.of(context).uri.path;
                              if (path.length == 1) {
                                return;
                              }
                              context.pushReplacement(
                                path.substring(0, path.lastIndexOf('/')),
                              );
                            },
                          ),
                        );
                      } else {
                        index--;
                      }
                      if (index == ClientManager.activeClients.length) {
                        return SizedBox.square(
                          dimension: 48,
                          child: IconButton(
                            tooltip: AppLocalizations.of(context).addAccount,
                            onPressed: manager.addLoginClient,
                            icon: const Icon(Icons.add),
                          ),
                        );
                      }
                      if (index == ClientManager.activeClients.length + 1) {
                        return SettingsButton(manager: manager);
                      }

                      return ClientScope(
                        client: ClientManager.activeClients[index],
                        child: Builder(
                          builder: (context) {
                            return ClientTab(manager);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
