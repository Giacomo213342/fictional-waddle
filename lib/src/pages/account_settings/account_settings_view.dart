import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'account_settings.dart';
import 'components/deactivate_account_tile.dart';
import 'components/manage_sessions_tile.dart';
import 'components/oidc_account_settings.dart';
import 'components/own_profile_preview.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key, required this.controller});

  final AccountSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).accountSettings),
      ),
      body: ListView(
        children: [
          OwnProfilePreview(client: controller.client),
          OidcAccountSettingsTile(controller),
          ManageSessionsTile(controller),
          const Divider(),
          DeactivateAccountTile(controller),
        ],
      ),
    );
  }
}
