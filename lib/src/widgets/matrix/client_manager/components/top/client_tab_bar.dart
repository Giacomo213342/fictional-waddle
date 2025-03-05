import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../scopes/client_scope.dart';
import '../../client_manager.dart';
import 'add_client_button.dart';
import 'draggable_client.dart';
import 'settings_button.dart';

class ClientTabBar extends StatelessWidget {
  const ClientTabBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        hint: AppLocalizations.of(context).regionAccountSwitcher,
        child: ValueListenableBuilder(
          valueListenable: ClientManager.of(context).store.activeClients,
          builder: (context, activeClients, _) => ListView.separated(
            itemCount: activeClients.length + 2,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index == activeClients.length) {
                return const AddClientButton();
              }
              if (index == activeClients.length + 1) {
                return const SettingsButton();
              }

              return ClientScope(
                client: activeClients[index],
                child: const DraggableClient(),
              );
            },
            separatorBuilder: (context, index) => index > activeClients.length
                ? const SizedBox()
                : Tooltip(
                    message: AppLocalizations.of(context).moveClientTooltip,
                    child: DragTarget<Client>(
                      builder: (context, accepted, rejected) => SizedBox(
                        width: index >= activeClients.length ? 8 : 16,
                      ),
                      onAcceptWithDetails: (details) =>
                          ClientManager.of(context)
                              .moveClient(details.data, index + 1),
                    ),
                  ),
          ),
        ),
      );
}
