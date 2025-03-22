import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/future_callback_builder.dart';
import '../../../widgets/matrix/sas_verification/sas_verification_request_widget.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';
import '../../../widgets/matrix/scopes/matrix_identifier_scope.dart';

class VerifyUserButton extends StatefulWidget {
  const VerifyUserButton({super.key});

  @override
  State<VerifyUserButton> createState() => _VerifyUserButtonState();
}

class _VerifyUserButtonState extends State<VerifyUserButton> {
  @override
  Widget build(BuildContext context) => FutureCallbackBuilder(
        callback: _verify,
        builder: (context, callback, _, __) => IconButton(
          onPressed: callback,
          tooltip: AppLocalizations.of(context).startVerification,
          icon: const Icon(Icons.shield),
        ),
      );

  Future<void> _verify() async {
    final client = ClientScope.of(context).client;
    final mxid = MatrixIdentifierScope.of(context).identifier.primaryIdentifier;

    final request = await client.userDeviceKeys[mxid]?.startVerification();
    if (request == null || !mounted) {
      return;
    }
    SasVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: client,
    );
  }
}
