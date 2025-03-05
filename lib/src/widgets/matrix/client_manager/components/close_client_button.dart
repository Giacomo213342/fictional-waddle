import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../pages/splash_screen/splash_screen.dart';
import '../../../../router/extensions/go_router_path_extension.dart';
import '../../scopes/client_scope.dart';
import '../client_manager.dart';
import '../client_store.dart';

class CloseClientButton extends StatelessWidget {
  const CloseClientButton({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    return SizedBox.square(
      dimension: 32,
      child: IconButton(
        onPressed: () {
          if (client.clientName.clientIdentifier ==
              GoRouterState.of(context).clientIdentifier) {
            final identifier = ClientManager.of(context)
                .store
                .activeClients
                .value
                .first
                .clientName
                .clientIdentifier;
            context.go(
              '/client/$identifier${SplashPage.routeName}',
            );
          }
          ClientManager.of(context).closeLoginClient(client);
        },
        iconSize: 12,
        icon: const Icon(Icons.close),
      ),
    );
  }
}
