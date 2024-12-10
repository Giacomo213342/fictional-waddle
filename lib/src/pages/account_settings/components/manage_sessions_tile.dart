import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../account_settings.dart';

class ManageSessionsTile extends StatelessWidget {
  const ManageSessionsTile(this.controller, {super.key});

  final AccountSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.devices),
      title: Text(AppLocalizations.of(context).manageSessions),
      onTap: controller.manageSessions,
    );
  }
}
