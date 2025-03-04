import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/future_callback_builder.dart';
import '../../../widgets/matrix/dialogs/display_name_dialog.dart';
import '../../../widgets/matrix/profile_builder.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';

class DisplayNameEditor extends StatelessWidget {
  const DisplayNameEditor({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final mxid = client.userID!;
    return SelectionArea(
      child: ProfileBuilder(
        userId: mxid,
        builder: (context, snapshot) => FutureCallbackBuilder(
          callback: () async {
            final uri = client.getOidcAccountManagementUri(
              action: OidcAccountManagementActions.profile,
            );
            // first check for OIDC support
            if (uri != null) {
              await launchUrl(uri);
            }
            // otherwise call the homeserver
            else {
              final displayName = await DisplayNameDialog(
                displayName:
                    snapshot.data?.displayName ?? mxid.localpart ?? mxid,
              ).show(context);
              if (displayName == null ||
                  displayName == snapshot.data?.displayName) {
                return;
              }
              await client.setDisplayName(mxid, displayName);
            }
          },
          builder: (context, callback, _, __) => Tooltip(
            message: AppLocalizations.of(context).changeDisplayName,
            child: TextButton(
              onPressed: callback,
              child: Text(
                snapshot.data?.displayName ?? mxid,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
