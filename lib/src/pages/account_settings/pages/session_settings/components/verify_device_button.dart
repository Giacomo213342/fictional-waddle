import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/future_callback_builder.dart';
import '../../../../../widgets/matrix/sas_verification/sas_verification_request_widget.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class VerifyDeviceButton extends StatefulWidget {
  const VerifyDeviceButton({super.key});

  @override
  State<VerifyDeviceButton> createState() => _VerifyDeviceButtonState();
}

class _VerifyDeviceButtonState extends State<VerifyDeviceButton> {
  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    final deviceKeys =
        client.userDeviceKeys[client.userID]?.deviceKeys[device.deviceId];
    return FutureCallbackBuilder(
      callback: deviceKeys == null ? null : _verifyKeys,
      builder: (context, callback, loading) => loading
          ? const AsciiProgressIndicator()
          : TextButton(
              onPressed: callback,
              child: Text(
                deviceKeys?.verified == true
                    ? AppLocalizations.of(context).verifyAgain
                    : AppLocalizations.of(context).verify,
              ),
            ),
    );
  }

  Future<void> _verifyKeys() async {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;

    final request = await client
        .userDeviceKeys[client.userID]?.deviceKeys[device.deviceId]
        ?.startVerification();
    if (request == null || !mounted) {
      return;
    }
    await SasVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: client,
    );
  }
}
