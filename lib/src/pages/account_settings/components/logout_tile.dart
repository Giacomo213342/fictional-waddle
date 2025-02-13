import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/matrix/dialogs/confirm_logout_dialog.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';

class LogoutTile extends StatelessWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.logout),
      title: Text(AppLocalizations.of(context).logout),
      onTap: () async {
        final client = ClientScope.of(context).client;
        final confirm = await const ConfirmLogoutDialog().show(context);
        if (confirm != true) {
          return;
        }
        await client.logout();
      },
    );
  }
}
