import 'package:flutter/material.dart';

import 'package:matrix/encryption/utils/bootstrap.dart';

import '../../../widgets/center_card.dart';
import '../ssss_bootstrap.dart';
import 'key_verification_container.dart';
import 'loading.dart';
import 'open_existing_ssss/open_existing_ssss.dart';

class BootstrapStateWidget extends StatelessWidget {
  const BootstrapStateWidget(this.controller, {super.key});

  final SsssBootstrapController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.bootstrap?.state) {
      case BootstrapState.openExistingSsss:
        final request = controller.keyVerificationRequest;
        if (request != null) {
          return CenterCard(
            child: KeyVerificationContainer(
              controller: controller,
              request: request,
            ),
          );
        }
        return OpenExistingSsssWidget(
          controller,
        );
      case BootstrapState.askUseExistingSsss:
      // TODO: Implement below cases, currently all other cases are implemented
      //  as loading widget
      case null:
      case BootstrapState.loading:
      case BootstrapState.askWipeSsss:
      // TODO: Handle this case.
      // TODO: Handle this case.
      case BootstrapState.askUnlockSsss:
      // TODO: Handle this case.
      case BootstrapState.askBadSsss:
      // TODO: Handle this case.
      case BootstrapState.askNewSsss:
      // TODO: Handle this case.
      case BootstrapState.askWipeCrossSigning:
      // TODO: Handle this case.
      case BootstrapState.askSetupCrossSigning:
      // TODO: Handle this case.
      case BootstrapState.askWipeOnlineKeyBackup:
      // TODO: Handle this case.
      case BootstrapState.askSetupOnlineKeyBackup:
      // TODO: Handle this case.
      case BootstrapState.error:
      // TODO: Handle this case.
      case BootstrapState.done:
      // TODO: Handle this case.
    }
    return const BootstrapLoading();
  }
}
