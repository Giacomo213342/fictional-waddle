import 'package:flutter/material.dart';

import 'components/bootstrap_state_widget.dart';
import 'ssss_bootstrap.dart';

class SsssBootstrapPageView extends StatelessWidget {
  const SsssBootstrapPageView(this.controller, {super.key});

  final SsssBootstrapController controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: SafeArea(
        child: Scaffold(
          body: BootstrapStateWidget(
            controller,
            key: ValueKey(controller.bootstrap?.state),
          ),
        ),
      ),
    );
  }
}
