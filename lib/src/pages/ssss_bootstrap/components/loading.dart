import 'package:flutter/material.dart';

import '../../../widgets/ascii_progress_indicator.dart';

class BootstrapLoading extends StatelessWidget {
  const BootstrapLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: AsciiProgressIndicator(),
    );
  }
}
