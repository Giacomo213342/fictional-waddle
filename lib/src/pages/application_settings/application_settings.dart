import 'package:flutter/material.dart';

import 'application_settings_view.dart';

class ApplicationSettingsPage extends StatefulWidget {
  const ApplicationSettingsPage({super.key});

  static const routeName = '/settings';

  @override
  State<ApplicationSettingsPage> createState() =>
      ApplicationSettingsController();
}

class ApplicationSettingsController extends State<ApplicationSettingsPage> {
  @override
  Widget build(BuildContext context) =>
      ApplicationSettingsView(controller: this);
}
