import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../account_settings.dart';

class OidcAccountSettingsTile extends StatelessWidget {
  const OidcAccountSettingsTile(this.controller, {super.key});

  final AccountSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.open_in_new),
      title: Text(AppLocalizations.of(context).accountSettings),
      onTap: controller.oidcAccountSettings,
    );
  }
}
