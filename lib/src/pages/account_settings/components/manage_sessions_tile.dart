import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../account_settings.dart';
import '../pages/session_settings/session_settings.dart';

class ManageSessionsTile extends StatelessWidget {
  const ManageSessionsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.devices),
      title: Text(AppLocalizations.of(context).manageSessions),
      onTap: () => context.pushMultiClient(
        AccountSettings.makeSettingsUri(
          SessionSettingsPage.routeName,
        ),
      ),
    );
  }
}
