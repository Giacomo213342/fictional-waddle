import 'package:flutter/material.dart';

import 'package:url_launcher/link.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/polycule_overflow_bar.dart';
import '../../../widgets/settings_manager.dart';

class ErrorReportingSettingsPage extends StatefulWidget {
  const ErrorReportingSettingsPage({super.key});

  static const routeName = 'sentry';

  @override
  State<ErrorReportingSettingsPage> createState() =>
      _ErrorReportingSettingsPageState();
}

class _ErrorReportingSettingsPageState
    extends State<ErrorReportingSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).errorReporting),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: Text(AppLocalizations.of(context).errorReportingLong),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context).errorReportingPrivacy),
          ),
          PolyculeOverflowBar(
            children: [
              Link(
                uri: Uri.parse(AppLocalizations.of(context).gitLabPrivacy),
                builder: (context, followLink) => TextButton(
                  onPressed: followLink,
                  child: Text(AppLocalizations.of(context).learnMore),
                ),
              ),
            ],
          ),
          ValueListenableBuilder(
            valueListenable: SettingsManager.of(context).sentryEnabled,
            builder: (context, sentryEnabled, _) => SwitchListTile(
              value: sentryEnabled,
              title: Text(AppLocalizations.of(context).enableSentry),
              onChanged: _toggleSentry,
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSentry(bool value) {
    SettingsManager.of(context).sentryEnabled.value = value;
  }
}
