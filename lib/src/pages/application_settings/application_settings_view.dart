import 'package:flutter/material.dart';

import '../../widgets/placeholder.dart';
import 'application_settings.dart';

class ApplicationSettingsView extends StatelessWidget {
  const ApplicationSettingsView({super.key, required this.controller});

  final ApplicationSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('There could be settings.'),
      ),
      body: const PolyculePlaceholder(),
    );
  }
}
