import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../avatar_builder/mxc_avatar.dart';
import '../../profile_builder.dart';
import '../../scopes/client_scope.dart';

class TabProfilePreview extends StatelessWidget {
  const TabProfilePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    return StreamBuilder(
      initialData: client.onLoginStateChanged.value,
      stream: client.onLoginStateChanged.stream
          // strip out soft logout
          .where((s) => s != LoginState.softLoggedOut),
      builder: (context, snapshot) {
        final client = ClientScope.of(context).client;
        final userId = client.userID;
        if (userId == null) {
          return Text(
            AppLocalizations.of(context).loggingInToClient,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          );
        }
        return Tooltip(
          message: userId,
          child: ProfileBuilder(
            key: ValueKey(userId),
            userId: userId,
            builder: (context, snapshot) {
              final profile = snapshot.data;
              return Text.rich(
                TextSpan(
                  children: [
                    WidgetSpan(
                      child: MxcAvatar(
                        uri: profile?.avatarUrl,
                        monogram: profile?.displayName ?? userId,
                        dimension: 24,
                      ),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    const TextSpan(text: ' '),
                    TextSpan(
                      text: profile?.displayName ?? profile?.userId ?? userId,
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              );
            },
          ),
        );
      },
    );
  }
}
