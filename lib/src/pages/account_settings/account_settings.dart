import 'package:flutter/material.dart';

import '../../utils/matrix/matrix_state.dart';
import '../../utils/matrix/oidc_delegation_extension.dart';
import '../account_selector/account_selector.dart';
import 'account_settings_view.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  static const routeName = '/settings';

  static Uri makeSettingsUri(String routeName) {
    return Uri.parse('${AccountSelectorPage.routeName}/$routeName');
  }

  @override
  State<AccountSettings> createState() => AccountSettingsController();
}

class AccountSettingsController extends MatrixState<AccountSettings> {
  @override
  Widget build(BuildContext context) => AccountSettingsView(controller: this);

  Future<void> oidcAccountSettings() async {
    await client.oidcAccountManagement();
  }

  Future<void> manageSessions() async {
    await client.oidcAccountManagement(
      action: OidcAccountManagementActions.sessionView,
    );
  }

  Future<void> deactivateAccount() async {
    await client.oidcAccountManagement(
      action: OidcAccountManagementActions.accountDeactivate,
    );
  }
}
