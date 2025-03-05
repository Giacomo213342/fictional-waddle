import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../pages/application_settings/application_settings.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(AppLocalizations.of(context).settings),
      onTap: () {
        Navigator.of(context).pop(ApplicationSettingsPage.routeName);
      },
      leading: const Icon(Icons.settings),
    );
  }
}
