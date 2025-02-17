import 'package:flutter/material.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../scopes/client_scope.dart';
import 'client_manager.dart';
import 'components/add_client_button.dart';
import 'components/client_back_button.dart';
import 'components/settings_button.dart';
import 'components/tab.dart';

class ClientTabBar extends StatelessWidget implements PreferredSizeWidget {
  const ClientTabBar({
    super.key,
    this.position = VerticalDirection.down,
  });

  final VerticalDirection position;

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, visible) => SafeArea(
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
                child: ValueListenableBuilder(
                  valueListenable:
                      ClientManager.of(context).store.activeClients,
                  builder: (context, activeClients, _) {
                    return ListView.separated(
                      itemCount: activeClients.length + 3,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return const ClientBackButton();
                        }
                        index--;
                        if (index == activeClients.length) {
                          return const AddClientButton();
                        }
                        if (index == activeClients.length + 1) {
                          return const SettingsButton();
                        }

                        return ClientScope(
                          key: Key(activeClients[index].clientName),
                          client: activeClients[index],
                          child: const ClientTab(),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          index > activeClients.length
                              ? const SizedBox()
                              : Tooltip(
                                  message: AppLocalizations.of(context)
                                      .moveClientTooltip,
                                  child: DragTarget<Client>(
                                    builder: (context, accepted, rejected) =>
                                        SizedBox(
                                      width: index == 0 ||
                                              index == activeClients.length
                                          ? 8
                                          : 16,
                                    ),
                                    onAcceptWithDetails: (details) =>
                                        ClientManager.of(context)
                                            .moveClient(details.data, index),
                                  ),
                                ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
