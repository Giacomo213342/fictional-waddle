import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';

class OidcSessionsIdpLink extends StatelessWidget {
  const OidcSessionsIdpLink({super.key});

  static List<Widget>? ifSupported(BuildContext context) {
    final client = ClientScope.of(context).client;
    final uri = client.getOidcAccountManagementUri(
      action: OidcAccountManagementActions.sessionsList,
    );
    if (uri == null) {
      return null;
    }
    return const [OidcSessionsIdpLink()];
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;

    return Link(
      uri: client.getOidcAccountManagementUri(
        action: OidcAccountManagementActions.sessionsList,
      ),
      builder: (context, followLink) => IconButton(
        onPressed: followLink,
        tooltip: AppLocalizations.of(context).openInIDP,
        icon: const Icon(Icons.open_in_new),
      ),
    );
  }
}
