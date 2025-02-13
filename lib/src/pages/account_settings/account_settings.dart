import 'package:flutter/material.dart';

import 'account_settings_view.dart';

class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  static const routeName = '/settings';

  static String makeSettingsUri(String routeName) {
    return '${AccountSettings.routeName}/$routeName';
  }

  @override
  Widget build(BuildContext context) => const AccountSettingsView();
}
