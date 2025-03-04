import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/future_callback_builder.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class DeleteDeviceButton extends StatelessWidget {
  const DeleteDeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureCallbackBuilder(
      callback: () async {
        final device = DeviceScope.of(context).device;
        final client = ClientScope.of(context).client;
        final oidcUri = client.getOidcAccountManagementUri(
          action: OidcAccountManagementActions.sessionEnd,
          deviceId: device.deviceId,
        );
        if (oidcUri != null) {
          await launchUrl(oidcUri);
        } else {
          await client.uiaRequestBackground(
            (auth) => client.deleteDevice(
              device.deviceId,
              auth: auth,
            ),
          );
        }
      },
      builder: (context, callback, loading, _) => loading
          ? const AsciiProgressIndicator()
          : TextButton(
              onPressed: callback,
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context).delete),
            ),
    );
  }
}
