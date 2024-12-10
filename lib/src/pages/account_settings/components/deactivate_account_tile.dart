import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../account_settings.dart';

class DeactivateAccountTile extends StatelessWidget {
  const DeactivateAccountTile(this.controller, {super.key});

  final AccountSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.delete_forever),
      title: Text(AppLocalizations.of(context).deactivateAccount),
      onTap: controller.deactivateAccount,
    );
  }
}
