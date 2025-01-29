import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../utils/file_selector.dart';
import '../../utils/matrix/oidc_delegation_extension.dart';
import '../../widgets/matrix/client_scope.dart';
import 'account_settings_view.dart';

class AccountSettings extends StatefulWidget {
  const AccountSettings({super.key});

  static const routeName = '/settings';

  static String makeSettingsUri(String routeName) {
    return '${AccountSettings.routeName}/$routeName';
  }

  @override
  State<AccountSettings> createState() => AccountSettingsController();
}

class AccountSettingsController extends State<AccountSettings> {
  @override
  Widget build(BuildContext context) => AccountSettingsView(controller: this);

  Future<void> oidcAccountSettings() async {
    await ClientScope.of(context).client.oidcAccountManagement();
  }

  Future<void> manageSessions() async {
    await ClientScope.of(context).client.oidcAccountManagement(
          action: OidcAccountManagementActions.sessionView,
        );
  }

  Future<void> deactivateAccount() async {
    await ClientScope.of(context).client.oidcAccountManagement(
          action: OidcAccountManagementActions.accountDeactivate,
        );
  }

  Future<void> editAvatar() async {
    final client = ClientScope.of(context).client;
    final selector = FileSelector(MessageTypes.Image);
    final openedFiles = await selector.selectFiles(
      context,
      enforceSingle: true,
    );
    if (!openedFiles || !mounted) {
      return;
    }
    final selection = await selector.previewSelection(
      context,
      allowCompress: false,
    );
    if (selection == null || selection.files.isEmpty || !mounted) {
      return;
    }
    final mxFiles = await selector.makeMatrixFiles(
      context,
      client.nativeImplementations,
    );

    await client.setAvatar(mxFiles.single.file);
  }

  Future<void> deleteAvatar() async {
    await ClientScope.of(context).client.setAvatar(null);
  }
}
