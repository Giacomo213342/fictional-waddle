import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';

class DeactivateAccountTile extends StatelessWidget {
  const DeactivateAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: ClientScope.of(context).client.getOidcAccountManagementUri(
            action: OidcAccountManagementActions.accountDeactivate,
          ),
      builder: (context, followLink) {
        return ListTile(
          leading: const Icon(Icons.delete_forever),
          title: Text(AppLocalizations.of(context).deactivateAccount),
          onTap: followLink,
        );
      },
    );
  }
}
