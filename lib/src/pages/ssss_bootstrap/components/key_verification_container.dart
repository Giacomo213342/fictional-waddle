import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';

import '../../../widgets/matrix/key_verification/key_verification_request_widget.dart';
import '../ssss_bootstrap.dart';
import 'bottom_progress_button_bar.dart';

class KeyVerificationContainer extends StatelessWidget {
  const KeyVerificationContainer({
    super.key,
    required this.request,
    required this.controller,
  });

  final KeyVerification request;
  final SsssBootstrapController controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (onPopInvoked) {
        controller.cancelSasVerification();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const CloseButton(),
        ),
        body: KeyVerificationRequestWidget(
          request,
          onClose: controller.sasVerificationSuccessful,
          buttonBarBuilder: (context, children) =>
              BottomProgressButtonBar(children: children),
        ),
      ),
    );
  }
}
