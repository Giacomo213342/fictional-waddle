import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/matrix/scopes/matrix_scope.dart';

class AskWipeSsssWidget extends StatelessWidget {
  const AskWipeSsssWidget({super.key});

  static Future<bool?> show(BuildContext context) {
    final scope = MatrixScope.captureAll(context);
    // UIA for OIDC is pretty buggy, let's settle preconditions in advance
    final oidcAction = scope.client.getOidcAccountManagementUri(
      action: OidcAccountManagementActions.crossSigningReset,
    );
    if (oidcAction != null) {
      launchUrl(oidcAction);
    }
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => MatrixScope(
        scope: scope,
        child: const AskWipeSsssWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).wipeAccount),
      content: Text(AppLocalizations.of(context).wipeAccountWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context).deleteAll),
        ),
      ],
    );
  }
}
