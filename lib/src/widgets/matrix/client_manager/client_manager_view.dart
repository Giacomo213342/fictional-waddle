import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../pages/splash_screen/splash_screen.dart';
import '../client_scope.dart';
import 'client_manager.dart';
import 'components/client_tab_bar.dart';

class ClientManagerView extends StatelessWidget {
  const ClientManagerView(this.manager, {super.key});

  final ClientManager manager;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: ClientManager.waiForInitialization,
      builder: (context, snapshot) {
        // while we're initializing, don't show the tab bar
        if (ClientManager.activeClients.isEmpty) {
          return const SplashPage();
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final tabBarOnTop =
                constraints.maxWidth > 764 || (!kIsWeb && Platform.isIOS);
            final client = manager.getActiveClient();
            return Material(
              child: Column(
                children: [
                  if (tabBarOnTop)
                    ClientTabBar(
                      manager,
                      position: VerticalDirection.up,
                    ),
                  Expanded(
                    child: client == null
                        ? manager.widget.child
                        : ClientScope(
                            client: client,
                            child: manager.widget.child,
                          ),
                  ),
                  if (!tabBarOnTop) ClientTabBar(manager),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
