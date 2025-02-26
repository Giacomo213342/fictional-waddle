import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import '../scopes/matrix_scope.dart';
import '../scopes/sas_scope.dart';
import 'components/compare_sas_widget.dart';
import 'components/incoming_verification_request_widget.dart';
import 'components/ssss_recovery_input.dart';
import 'components/verification_request_error_widget.dart';
import 'components/verification_successful_widget.dart';
import 'components/waiting_peer_widget.dart';

typedef ButtonBarBuilder = Widget Function(
  BuildContext context,
  List<Widget> children,
);

class SasVerificationRequestWidget extends StatefulWidget {
  const SasVerificationRequestWidget({super.key});

  @override
  State<SasVerificationRequestWidget> createState() =>
      _SasVerificationRequestWidgetState();

  static Future<void> showDialog(
    KeyVerification verification, {
    required BuildContext context,
    required Client client,
  }) {
    return showModalBottomSheet(
      context: context,
      isDismissible: false,
      useRootNavigator: true,
      builder: (context) => MatrixScope(
        scope: ScopeCapture(client: client, verification: verification),
        child: const SasVerificationRequestWidget(),
      ),
    );
  }
}

class _SasVerificationRequestWidgetState
    extends State<SasVerificationRequestWidget> {
  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    verification.onUpdate ??= handleNextStep;

    switch (verification.state) {
      case KeyVerificationState.askAccept:
        return const PopScope(
          canPop: false,
          child: IncomingVerificationRequestWidget(),
        );
      case KeyVerificationState.askSSSS:
        return const PopScope(
          canPop: false,
          child: SsssRecoveryInput(),
        );
      loading:
      case KeyVerificationState.askChoice:
      case KeyVerificationState.waitingAccept:
        return const PopScope(
          canPop: false,
          child: WaitingPeerWidget(),
        );
      case KeyVerificationState.askSas:
        return const PopScope(
          canPop: false,
          child: CompareSasWidget(),
        );
      case KeyVerificationState.showQRSuccess:
      case KeyVerificationState.confirmQRScan:
        throw UnimplementedError(
          'QR verification is not supported by this client.',
        );

      case KeyVerificationState.error:
        if (verification.canceledCode == 'm.accepted' ||
            verification.canceledReason == 'm.accepted') {
          continue loading;
        }
        return const PopScope(
          canPop: false,
          child: VerificationRequestErrorWidget(),
        );
      case KeyVerificationState.waitingSas:
      case KeyVerificationState.done:
        return const VerificationSuccessfulWidget();
    }
  }

  void handleNextStep() {
    if (mounted) {
      setState(() {});
    }
  }
}
