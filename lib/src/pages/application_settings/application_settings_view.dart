import 'package:flutter/material.dart';

import 'package:url_launcher/link.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'application_settings.dart';
import 'pages/appearance.dart';
import 'pages/logs.dart';
import 'pages/push.dart';

class ApplicationSettingsView extends StatelessWidget {
  const ApplicationSettingsView({super.key, required this.controller});

  final ApplicationSettingsController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).polyculeSettings),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        children: [
          Link(
            uri: ApplicationSettingsPage.makeSettingsUri(
              AppearanceSettingsPage.routeName,
            ),
            builder: (context, followLink) => ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(
                AppLocalizations.of(context).appearanceAccessibilitySettings,
              ),
              onTap: followLink,
            ),
          ),
          Link(
            uri: ApplicationSettingsPage.makeSettingsUri(
              PushSettingsPage.routeName,
            ),
            builder: (context, followLink) => ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(
                AppLocalizations.of(context).pushSettings,
              ),
              onTap: followLink,
            ),
          ),
          Link(
            uri: ApplicationSettingsPage.makeSettingsUri(
              LogsPage.routeName,
            ),
            builder: (context, followLink) => ListTile(
              leading: const Icon(Icons.developer_mode),
              title: Text(
                AppLocalizations.of(context).logs,
              ),
              onTap: followLink,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(AppLocalizations.of(context).language),
            onTap: controller.showLanguageDialog,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(AppLocalizations.of(context).aboutPolycule),
            onTap: controller.showAboutDialog,
          ),
        ],
      ),
    );
  }
}
