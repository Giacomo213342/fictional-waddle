import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/matrix/key_verification/key_verification_request_widget.dart';
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/device_scope.dart';

class VerifyDeviceButton extends StatefulWidget {
  const VerifyDeviceButton({super.key});

  @override
  State<VerifyDeviceButton> createState() => _VerifyDeviceButtonState();
}

class _VerifyDeviceButtonState extends State<VerifyDeviceButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    final deviceKeys =
        client.userDeviceKeys[client.userID]?.deviceKeys[device.deviceId];
    return TextButton(
      onPressed: _loading || deviceKeys == null ? null : _startKeyVerification,
      child: _loading
          ? const AsciiProgressIndicator()
          : Text(
              deviceKeys?.verified == true
                  ? AppLocalizations.of(context).verifyAgain
                  : AppLocalizations.of(context).verify,
            ),
    );
  }

  Future<void> _startKeyVerification() async {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;
    setState(() {
      _loading = true;
    });

    final request = await client
        .userDeviceKeys[client.userID]?.deviceKeys[device.deviceId]
        ?.startVerification();
    if (request == null || !mounted) {
      return;
    }
    await KeyVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: client,
    );
    setState(() {
      _loading = false;
    });
  }
}
