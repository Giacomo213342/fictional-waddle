import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';

class OidcAccountSettingsTile extends StatelessWidget {
  const OidcAccountSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Link(
      uri: ClientScope.of(context).client.getOidcAccountManagementUri(),
      builder: (context, followLink) {
        return ListTile(
          leading: const Icon(Icons.open_in_new),
          title: Text(AppLocalizations.of(context).accountSettings),
          onTap: followLink,
        );
      },
    );
  }
}
