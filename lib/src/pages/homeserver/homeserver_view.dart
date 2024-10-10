import 'package:flutter/material.dart';

import 'package:url_launcher/link.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/fonts.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/polycule_overflow_bar.dart';
import '../application_settings/application_settings.dart';
import '../application_settings/pages/appearance.dart';
import 'components/benchmark.dart';
import 'components/homeserver_input.dart';
import 'homeserver.dart';

class HomeserverView extends StatelessWidget {
  const HomeserverView(this.controller, {super.key});

  final HomeserverController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 786),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            AppLocalizations.of(context).homeserverHeadline,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            AppLocalizations.of(context).aMatrixClient,
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 64),
                          const HomeserverInput(),
                          const Divider(),
                          ExpansionTile(
                            title: Text(
                              AppLocalizations.of(context).discoverHomeservers,
                            ),
                            subtitle: Text(
                              AppLocalizations.of(context).newToMatrixLong,
                            ),
                            onExpansionChanged:
                                controller.handleHomeserverListExpansion,
                            children: [
                              if (controller.recommendationsLoading)
                                Focus(
                                  autofocus: true,
                                  child: Semantics(
                                    hint: AppLocalizations.of(context)
                                        .loadingHomeservers,
                                    child: const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Center(
                                        child: AsciiProgressIndicator(),
                                      ),
                                    ),
                                  ),
                                ),
                              ...controller.recommendations
                                  .map((e) => BenchmarkWidget(e)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PolyculeOverflowBar(
              children: [
                Link(
                  uri: ApplicationSettingsPage.makeSettingsUri(
                    AppearanceSettingsPage.routeName,
                  ),
                  builder: (context, followLink) {
                    return OutlinedButton.icon(
                      onPressed: followLink,
                      icon: const Icon(Icons.settings_accessibility),
                      label: Text(
                        AppLocalizations.of(context)
                            .appearanceAccessibilitySettings,
                        style: TextStyle(
                          fontFamily: PolyculeFonts.inclusiveSans.name,
                        ),
                      ),
                    );
                  },
                ),
                OutlinedButton.icon(
                  onPressed: controller.showAboutDialog,
                  icon: const Icon(Icons.info),
                  label: Text(AppLocalizations.of(context).about),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
