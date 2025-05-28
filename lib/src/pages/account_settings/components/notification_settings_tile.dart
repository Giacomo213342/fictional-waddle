import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../account_settings.dart';
import '../pages/notification_settings/notification_settings.dart';

class NotificationSettingsTile extends StatelessWidget {
  const NotificationSettingsTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.notifications),
      title: Text(
        AppLocalizations.of(context).notificationSettings,
      ),
      onTap: () => context.pushMultiClient(
        AccountSettings.makeSettingsUri(
          NotificationSettingsPage.routeName,
        ),
      ),
    );
  }
}
