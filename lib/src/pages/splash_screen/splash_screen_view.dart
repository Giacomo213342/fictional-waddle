import 'package:flutter/material.dart';

import '../../widgets/ascii_progress_indicator.dart';
import 'splash_screen.dart';

class SplashPageView extends StatelessWidget {
  const SplashPageView(this.controller, {super.key});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: AsciiProgressIndicator(),
      ),
    );
  }
}
