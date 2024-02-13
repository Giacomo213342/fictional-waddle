import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'client_manager.dart';
import 'components/client_tab_bar.dart';

class ClientManagerView extends StatelessWidget {
  const ClientManagerView(this.manager, {super.key});

  final ClientManager manager;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabBarOnTop = constraints.maxWidth > 960;
          return Column(
            children: [
              if (tabBarOnTop) ClientTabBar(manager),
              Expanded(
                child: InheritedProvider<GetClientCallback>(
                  create: (context) => manager.getActiveClient,
                  child: Builder(
                    builder: (context) {
                      return manager.widget.child;
                    },
                  ),
                ),
              ),
              if (!tabBarOnTop) ClientTabBar(manager),
            ],
          );
        },
      ),
    );
  }
}
