import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../client_manager.dart';
import 'tab.dart';

class ClientTabBar extends StatelessWidget {
  const ClientTabBar(this.manager, {super.key});

  final ClientManager manager;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      left: true,
      right: true,
      maintainBottomViewPadding: true,
      child: SizedBox(
        height: 48,
        child: Semantics(
          hint: AppLocalizations.of(context).regionAccountSwitcher,
          child: ListView.builder(
            itemCount: ClientManager.activeClients.length + 3,
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SizedBox.square(
                  dimension: 48,
                  child: BackButton(onPressed: context.pop),
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
                return SizedBox.square(
                  dimension: 48,
                  child: IconButton(
                    tooltip: AppLocalizations.of(context).settings,
                    onPressed: manager.openSettings,
                    icon: const Icon(Icons.settings),
                  ),
                );
              }

              return InheritedProvider<GetClientCallback>(
                create: (context) => () => ClientManager.activeClients[index],
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
    );
  }
}
