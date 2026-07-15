import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../application_settings/application_settings.dart';
import '../room_list/room_list.dart';
import 'components/deactivate_account_tile.dart';
import 'components/emoji_settings_tile.dart';
import 'components/logout_tile.dart';
import 'components/manage_sessions_tile.dart';
import 'components/mxid_qr_code_tile.dart';
import 'components/notification_settings_tile.dart';
import 'components/oidc_account_settings.dart';
import 'components/own_profile_preview.dart';
import 'components/ssss_available_tile.dart';

class AccountSettingsView extends StatelessWidget {
  const AccountSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    void leaveSettings() => context.goMultiClient(RoomListPage.routeName);

    return BackButtonListener(
      onBackButtonPressed: () async {
        leaveSettings();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(onPressed: leaveSettings),
          title: Text(AppLocalizations.of(context).accountSettings),
        ),
        body: ListView(
          children: [
            const OwnProfilePreview(),
            const MxidQRCodeTile(),
            const SSSSAvailableTile(),
            const EmojiSettingsTile(),
            const NotificationSettingsTile(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(AppLocalizations.of(context).polyculeSettings),
              onTap: () => context.push(ApplicationSettingsPage.routeName),
            ),
            if (client.getOidcAccountManagementUri() != null)
              const OidcAccountSettingsTile(),
            const ManageSessionsTile(),
            const Divider(),
            const LogoutTile(),
            if (client.getOidcAccountManagementUri(
                  action: OidcAccountManagementActions.accountDeactivate,
                ) !=
                null)
              const DeactivateAccountTile(),
          ],
        ),
      ),
    );
  }
}
