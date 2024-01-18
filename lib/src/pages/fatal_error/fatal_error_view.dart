import 'package:flutter/material.dart';

import 'fatal_error_page.dart';

class FatalErrorView extends StatelessWidget {
  const FatalErrorView(this.controller, {super.key});

  final FatalErrorController controller;

  @override
  Widget build(BuildContext context) {
    // TODO: design a proper error page
    return Scaffold(
      body: Center(
        child: Text('Fatal error: ${controller.error}'),
      ),
    );
  }
}
