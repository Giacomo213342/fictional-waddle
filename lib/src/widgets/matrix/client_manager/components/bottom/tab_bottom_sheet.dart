import 'package:flutter/material.dart';

import '../../../scopes/client_scope.dart';
import '../../client_manager.dart';
import 'add_account_tile.dart';
import 'client_tile.dart';
import 'settings_tile.dart';

class TabBottomSheet extends StatelessWidget {
  const TabBottomSheet({super.key});

  Future<String?> show(BuildContext context) async {
    return showModalBottomSheet<String>(
      context: context,
      // we need the [ClientManager] in the Widget tree
      useRootNavigator: false,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ValueListenableBuilder(
        valueListenable: ClientManager.of(context).store.activeClients,
        builder: (context, activeClients, _) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: activeClients.length,
                itemBuilder: (context, index) {
                  return ClientScope(
                    key: Key(activeClients[index].clientName),
                    client: activeClients[index],
                    child: const ClientTile(),
                  );
                },
                onReorder: (int oldIndex, int newIndex) async {
                  if (oldIndex >= activeClients.length) {
                    return;
                  }
                  await ClientManager.of(context)
                      .moveClient(activeClients[oldIndex], newIndex);
                },
              ),
              const AddAccountTile(),
              const SettingsTile(),
            ],
          );
        },
      ),
    );
  }
}
