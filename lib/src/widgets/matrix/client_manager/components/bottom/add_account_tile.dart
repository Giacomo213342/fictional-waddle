import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../pages/splash_screen/splash_screen.dart';
import '../../client_manager.dart';

class AddAccountTile extends StatelessWidget {
  const AddAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        final identifier = ClientManager.of(context).addLoginClient();
        Navigator.of(context).pop('/client/$identifier${SplashPage.routeName}');
      },
      title: Text(AppLocalizations.of(context).addAccount),
      leading: const Icon(Icons.add),
    );
  }
}
