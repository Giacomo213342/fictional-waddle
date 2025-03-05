import 'package:flutter/material.dart';

import '../../../scopes/client_scope.dart';
import '../../client_manager.dart';
import '../tab.dart';

final _tabBarGlobalKey = GlobalKey();

class ClientTabBar extends StatelessWidget {
  const ClientTabBar({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: ClientManager.of(context).store.activeClients,
        builder: (context, activeClients, _) => ListView.builder(
          key: _tabBarGlobalKey,
          scrollDirection: Axis.horizontal,
          itemCount: activeClients.length,
          itemBuilder: (context, index) {
            final client = activeClients[index];
            return ClientScope(
              client: client,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Center(
                  child: ClientTab(),
                ),
              ),
            );
          },
        ),
      );
}
