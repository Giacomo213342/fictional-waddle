import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

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
        child: ListView.builder(
          itemCount: ClientManager.activeClients.length + 1,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            if (index == ClientManager.activeClients.length) {
              return SizedBox.square(
                dimension: 48,
                child: IconButton(
                  onPressed: manager.addLoginClient,
                  icon: const Icon(Icons.add),
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
    );
  }
}
