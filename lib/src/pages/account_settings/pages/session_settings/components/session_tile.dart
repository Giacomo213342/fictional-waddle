import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../theme/fonts.dart';
import '../../../../../widgets/human_date.dart';
import '../../../../../widgets/matrix/key_trust_icon_theme.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';
import '../../../../../widgets/matrix/scopes/session_scope.dart';
import '../../../../../widgets/matrix/verify_device_button.dart';
import '../../../../../widgets/polycule_overflow_bar.dart';
import 'delete_device_button.dart';
import 'idp_device_link_button.dart';
import 'key_trust_tile.dart';
import 'rename_device_button.dart';

class SessionTile extends StatelessWidget {
  const SessionTile({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    final ip = device.lastSeenIp;
    final lastSeen = device.lastSeenTs;

    final idpLinkButton = IdpDeviceLinkButton.ifSupported(context);

    final deviceKeys =
        client.userDeviceKeys[client.userID]?.deviceKeys[device.deviceId];
    return ExpansionTile(
      leading: const KeyTrustIconTheme(child: Icon(Icons.devices)),
      title: Text(device.displayName ?? device.deviceId),
      initiallyExpanded: device.deviceId == client.deviceID,
      children: [
        ListTile(
          leading: Tooltip(
            message: AppLocalizations.of(context).sessionId,
            child: const Icon(Icons.numbers),
          ),
          title: SelectableText(
            device.deviceId,
            style: TextStyle(fontFamily: PolyculeFonts.notoSansMono.name),
          ),
          subtitle: device.deviceId == client.deviceID
              ? Text(AppLocalizations.of(context).yourCurrentDevice)
              : null,
        ),
        const KeyTrustTile(),
        if (ip != null)
          ListTile(
            leading: Tooltip(
              message: AppLocalizations.of(context).sessionIpAddress,
              child: const Icon(Icons.dns),
            ),
            title: SelectableText(ip),
          ),
        if (lastSeen != null)
          ListTile(
            leading: Tooltip(
              message: AppLocalizations.of(context).sessionLastSeen,
              child: const Icon(Icons.history),
            ),
            title: Text(
              DateTime.fromMillisecondsSinceEpoch(lastSeen)
                  .humanShortDate(context: context),
            ),
          ),
        if (device.deviceId != client.deviceID)
          PolyculeOverflowBar(
            children: [
              if (idpLinkButton != null) idpLinkButton,
              const RenameDeviceButton(),
              if (deviceKeys != null)
                SessionScope(
                  session: deviceKeys,
                  child: const VerifyDeviceButton(),
                ),
              const DeleteDeviceButton(),
            ],
          ),
      ],
    );
  }
}
