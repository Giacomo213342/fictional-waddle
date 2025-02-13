import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class IdpDeviceLinkButton extends StatelessWidget {
  const IdpDeviceLinkButton({super.key});

  static Widget? ifSupported(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    final uri = client.getOidcAccountManagementUri(
      action: OidcAccountManagementActions.sessionView,
      deviceId: device.deviceId,
    );
    if (uri == null) {
      return null;
    }
    return const IdpDeviceLinkButton();
  }

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    return Link(
      uri: client.getOidcAccountManagementUri(
        action: OidcAccountManagementActions.sessionView,
        deviceId: device.deviceId,
      ),
      builder: (context, followLink) => TextButton(
        onPressed: followLink,
        child: Text(AppLocalizations.of(context).openInIDP),
      ),
    );
  }
}
