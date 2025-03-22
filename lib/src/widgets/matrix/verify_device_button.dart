import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../ascii_progress_indicator.dart';
import '../future_callback_builder.dart';
import 'sas_verification/sas_verification_request_widget.dart';
import 'scopes/client_scope.dart';
import 'scopes/session_scope.dart';

class VerifyDeviceButton extends StatefulWidget {
  const VerifyDeviceButton({super.key});

  @override
  State<VerifyDeviceButton> createState() => _VerifyDeviceButtonState();
}

class _VerifyDeviceButtonState extends State<VerifyDeviceButton> {
  @override
  Widget build(BuildContext context) {
    final deviceKeys = SessionScope.of(context).session;
    return FutureCallbackBuilder(
      callback: _verifyKeys,
      builder: (context, callback, loading, _) => loading
          ? const AsciiProgressIndicator()
          : TextButton(
              onPressed: callback,
              child: Text(
                deviceKeys.verified == true
                    ? AppLocalizations.of(context).verifyAgain
                    : AppLocalizations.of(context).verify,
              ),
            ),
    );
  }

  Future<void> _verifyKeys() async {
    final client = ClientScope.of(context).client;
    final request = await SessionScope.of(context).session.startVerification();
    if (!mounted) {
      return;
    }
    await SasVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: client,
    );
  }
}
