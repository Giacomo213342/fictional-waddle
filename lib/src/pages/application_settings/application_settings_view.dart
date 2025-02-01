import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'application_settings.dart';
import 'pages/appearance.dart';
import 'pages/error_reporting.dart';
import 'pages/logs.dart';
import 'pages/network.dart';
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
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: Text(
              AppLocalizations.of(context).appearanceAccessibilitySettings,
            ),
            onTap: () => context.push(
              ApplicationSettingsPage.makeSettingsUri(
                AppearanceSettingsPage.routeName,
              ),
            ),
          ),
          if (kIsWeb ||
              (!Platform.isIOS && !Platform.isMacOS && !Platform.isWindows))
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(
                AppLocalizations.of(context).pushSettings,
              ),
              onTap: () => context.push(
                ApplicationSettingsPage.makeSettingsUri(
                  PushSettingsPage.routeName,
                ),
              ),
            ),
          if (!kIsWeb)
            ListTile(
              leading: const Icon(Icons.settings_ethernet),
              title: Text(
                AppLocalizations.of(context).networkSettings,
              ),
              onTap: () => context.push(
                ApplicationSettingsPage.makeSettingsUri(
                  NetworkSettingsPage.routeName,
                ),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.translate),
            title: Text(AppLocalizations.of(context).language),
            onTap: controller.showLanguageDialog,
          ),
          ListTile(
            leading: const Icon(Icons.error),
            title: Text(
              AppLocalizations.of(context).errorReporting,
            ),
            onTap: () => context.push(
              ApplicationSettingsPage.makeSettingsUri(
                ErrorReportingSettingsPage.routeName,
              ),
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.developer_mode),
            title: Text(
              AppLocalizations.of(context).logs,
            ),
            onTap: () => context.push(
              ApplicationSettingsPage.makeSettingsUri(
                LogsPage.routeName,
              ),
            ),
          ),
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
