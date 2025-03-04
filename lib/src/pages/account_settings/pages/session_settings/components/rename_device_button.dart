import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/future_callback_builder.dart';
import '../../../../../widgets/matrix/dialogs/rename_device_dialog.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class RenameDeviceButton extends StatelessWidget {
  const RenameDeviceButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureCallbackBuilder(
      callback: () async {
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
      builder: (context, callback, loading, _) => loading
          ? const AsciiProgressIndicator()
          : TextButton(
              onPressed: callback,
              child: Text(AppLocalizations.of(context).rename),
            ),
    );
  }
}
