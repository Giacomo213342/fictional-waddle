import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class DeleteDeviceButton extends StatelessWidget {
  const DeleteDeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        final device = DeviceScope.of(context).device;
        final client = ClientScope.of(context).client;
        final oidcUri = client.getOidcAccountManagementUri(
          action: OidcAccountManagementActions.sessionEnd,
          deviceId: device.deviceId,
        );
        if (oidcUri != null) {
          launchUrl(oidcUri);
        } else {
          client.uiaRequestBackground(
            (auth) => client.deleteDevice(
              device.deviceId,
              auth: auth,
            ),
          );
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.error,
      ),
      child: Text(AppLocalizations.of(context).delete),
    );
  }
}
