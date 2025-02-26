import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../../pages/splash_screen/splash_screen.dart';
import '../../../../router/extensions/go_router_path_extension.dart';
import '../../scopes/matrix_scope.dart';
import '../client_store.dart';
import 'close_client_button.dart';
import 'tab_profile_preview.dart';

class ClientTab extends StatelessWidget {
  const ClientTab({super.key});

  static final _radius = BorderRadius.circular(0);

  @override
  Widget build(BuildContext context) {
    final scope = MatrixScope.captureAll(context);
    final client = scope.client;
    final body = MatrixScope(
      scope: scope,
      child: ClipRRect(
        borderRadius: _radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: client.clientName.clientIdentifier ==
                    GoRouterState.of(context).clientIdentifier
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .25)
                : null,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: _radius,
          ),
          child: InkWell(
            onTap: () => context.pushMultiClient(
              '/client/${client.clientName.clientIdentifier}${SplashPage.routeName}',
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Center(
                child: StreamBuilder<LoginState>(
                  initialData: client.onLoginStateChanged.value,
                  stream: client.onLoginStateChanged.stream
                      // strip out soft logout
                      .where((s) => s != LoginState.softLoggedOut),
                  builder: (context, snapshot) => Row(
                    children: [
                      SizedBox(
                        width: client.userID != null ? 224 : 224 - 32,
                        child: const TabProfilePreview(),
                      ),
                      if (!client.isLogged()) const CloseClientButton(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LongPressDraggable<Client>(
        data: client,
        feedback: Material(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: SizedBox(height: 38, child: body),
        ),
        childWhenDragging: body,
        child: body,
      ),
    );
  }
}
