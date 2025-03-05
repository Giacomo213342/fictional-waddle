import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../pages/splash_screen/splash_screen.dart';
import '../../../avatar_builder/mxc_avatar.dart';
import '../../../profile_builder.dart';
import '../../../scopes/client_scope.dart';
import '../../client_store.dart';

class ClientTile extends StatelessWidget {
  const ClientTile({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;

    Widget? subtitle;

    final userId = client.userID;
    final homeserver = client.homeserver;
    if (userId != null) {
      subtitle = Text(userId);
    } else if (homeserver != null) {
      subtitle = Text(homeserver.toString());
    }
    return StreamBuilder<LoginState>(
      initialData: client.onLoginStateChanged.value,
      stream: client.onLoginStateChanged.stream
          // strip out soft logout
          .where((s) => s != LoginState.softLoggedOut),
      builder: (context, snapshot) => ListTile(
        onTap: () {
          Navigator.of(context).pop(
            '/client/${client.clientName.clientIdentifier}${SplashPage.routeName}',
          );
        },
        leading: userId == null
            ? const Icon(Icons.person_add)
            : ProfileBuilder(
                userId: userId,
                builder: (context, snapshot) => MxcAvatar(
                  uri: snapshot.data?.avatarUrl,
                  monogram: snapshot.data?.displayName ?? userId,
                  dimension: 24,
                ),
              ),
        title: userId == null
            ? Text(
                AppLocalizations.of(context).loggingInToClient,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )
            : ProfileBuilder(
                userId: userId,
                builder: (context, snapshot) => Text(
                  snapshot.data?.displayName ??
                      snapshot.data?.userId.localpart ??
                      userId,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
        subtitle: subtitle,
      ),
    );
  }
}
