import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/dialogs/rename_device_dialog.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class RenameDeviceButton extends StatelessWidget {
  const RenameDeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        final device = DeviceScope.of(context).device;
        final client = ClientScope.of(context).client;

        final updatedName = await const RenameDeviceDialog().show(context);

        if (updatedName == null) {
          return;
        }
        await client.updateDevice(
          device.deviceId,
          displayName: updatedName.isEmpty ? device.deviceId : updatedName,
        );
      },
      child: Text(AppLocalizations.of(context).rename),
    );
  }
}
