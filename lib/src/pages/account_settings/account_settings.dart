import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/file_selector.dart';
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
    final uri = ClientScope.of(context).client.getOidcAccountManagementUri();
    if (uri == null) {
      return;
    }
    launchUrl(uri);
  }

  Future<void> manageSessions() async {
    final uri = ClientScope.of(context).client.getOidcAccountManagementUri(
          action: OidcAccountManagementActions.sessionView,
        );
    if (uri == null) {
      return;
    }
    launchUrl(uri);
  }

  Future<void> deactivateAccount() async {
    final uri = ClientScope.of(context).client.getOidcAccountManagementUri(
          action: OidcAccountManagementActions.accountDeactivate,
        );
    if (uri == null) {
      return;
    }
    launchUrl(uri);
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
