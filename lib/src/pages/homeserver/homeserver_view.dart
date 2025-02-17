import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/fonts.dart';
import '../../utils/about_dialog.dart';
import '../../widgets/polycule_overflow_bar.dart';
import '../application_settings/application_settings.dart';
import '../application_settings/pages/appearance.dart';
import 'components/homeserver_input.dart';
import 'components/homeserver_recommendation_card.dart';

class HomeserverView extends StatelessWidget {
  const HomeserverView({super.key});

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
                          const HomeserverRecommendationCard(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            PolyculeOverflowBar(
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    ApplicationSettingsPage.makeSettingsUri(
                      AppearanceSettingsPage.routeName,
                    ),
                  ),
                  icon: const Icon(Icons.settings_accessibility),
                  label: Text(
                    AppLocalizations.of(context)
                        .appearanceAccessibilitySettings,
                    style: TextStyle(
                      fontFamily: PolyculeFonts.inclusiveSans.name,
                    ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => showInfoDialog(context),
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
