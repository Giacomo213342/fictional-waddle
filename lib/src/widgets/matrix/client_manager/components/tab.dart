import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../pages/splash_screen/splash_screen.dart';
import '../../../../router/extensions/go_router_path_extension.dart';
import '../../scopes/client_scope.dart';
import '../client_store.dart';
import 'close_client_button.dart';
import 'top/tab_profile_preview.dart';

class ClientTab extends StatelessWidget implements PreferredSizeWidget {
  const ClientTab({super.key});

  static final _radius = BorderRadius.circular(0);

  @override
  Size get preferredSize => const Size(256, 38);

  @override
  Widget build(BuildContext context) {
    GoRouterState? goRouterState;
    try {
      goRouterState = GoRouterState.of(context);
    } catch (_) {}

    final client = ClientScope.of(context).client;
    return SizedBox.fromSize(
      size: preferredSize,
      child: Container(
        decoration: BoxDecoration(
          color: client.clientName.clientIdentifier ==
                  goRouterState?.clientIdentifier
              ? Theme.of(context).colorScheme.primary.withValues(alpha: .25)
              : null,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: _radius,
        ),
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () => context.pushMultiClient(
            '/client/${client.clientName.clientIdentifier}${SplashPage.routeName}',
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            child: StreamBuilder<LoginState>(
              initialData: client.onLoginStateChanged.value,
              stream: client.onLoginStateChanged.stream
                  // strip out soft logout
                  .where((s) => s != LoginState.softLoggedOut),
              builder: (context, snapshot) => Row(
                children: [
                  Expanded(
                    child: Tooltip(
                      message: client.userID ??
                          client.homeserver?.toString() ??
                          AppLocalizations.of(context).loggingInToClient,
                      child: const TabProfilePreview(),
                    ),
                  ),
                  if (snapshot.data == LoginState.loggedOut)
                    const CloseClientButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
