import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../avatar_builder/mxc_avatar.dart';
import '../../profile_builder.dart';
import '../../scopes/client_scope.dart';
import '../../scopes/matrix_scope.dart';
import '../client_manager.dart';

class ClientTab extends StatelessWidget {
  const ClientTab(this.manager, {super.key});

  static final _radius = BorderRadius.circular(0);

  final ClientManager manager;

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final userId = client.userID;
    final scope = MatrixScope.captureAll(context);
    final body = MatrixScope(
      scope: scope,
      child: ClipRRect(
        borderRadius: _radius,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: client.clientName.clientIdentifier ==
                    manager.widget.activeClientIdentifier
                ? Theme.of(context).colorScheme.primary.withValues(alpha: .25)
                : null,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
            borderRadius: _radius,
          ),
          child: InkWell(
            onTap: () => manager.setActiveClient(client),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              child: Center(
                child: Row(
                  children: [
                    SizedBox(
                      width: userId != null ? 224 : 224 - 32,
                      child: userId == null
                          ? Text(
                              AppLocalizations.of(context).loggingInToClient,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            )
                          : Tooltip(
                              message: userId,
                              child: ProfileBuilder(
                                userId: userId,
                                builder: (context, snapshot) {
                                  final profile = snapshot.data;
                                  return Text.rich(
                                    TextSpan(
                                      children: [
                                        WidgetSpan(
                                          child: MxcAvatar(
                                            uri: profile?.avatarUrl,
                                            monogram:
                                                profile?.displayName ?? userId,
                                            dimension: 24,
                                          ),
                                          alignment:
                                              PlaceholderAlignment.middle,
                                        ),
                                        const TextSpan(text: ' '),
                                        TextSpan(
                                          text: profile?.displayName ??
                                              profile?.userId ??
                                              client.userID!,
                                        ),
                                      ],
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ),
                    ),
                    if (!client.isLogged())
                      SizedBox(
                        width: 32,
                        child: IconButton(
                          onPressed: () => manager.closeLoginClient(client),
                          iconSize: 12,
                          icon: const Icon(Icons.close),
                        ),
                      ),
                  ],
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
