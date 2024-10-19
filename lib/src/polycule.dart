import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'router/router.dart';
import 'theme/theme_builder.dart';
import 'widgets/settings_manager.dart';

class PolyculeClient extends StatelessWidget {
  const PolyculeClient({super.key});

  static final router = PolyculeRouter();

  @override
  Widget build(BuildContext context) {
    return SettingsBuilder(
      builder: (context) {
        return PolyculeThemeBuilder(
          builder: (
            mode,
            dark,
            light,
            highContrastDark,
            highContrastLight,
            preferHighContrast,
          ) {
            return ValueListenableBuilder<Locale?>(
              valueListenable: SettingsManager.of(context).locale,
              builder: (context, locale, _) {
                return MaterialApp.router(
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appName,
                  locale: locale,
                  theme: preferHighContrast ? highContrastLight : light,
                  darkTheme: preferHighContrast ? highContrastDark : dark,
                  highContrastDarkTheme: highContrastDark,
                  highContrastTheme: highContrastLight,
                  themeMode: mode,
                  routerConfig: router,
                  builder: PolyculeThemeBuilder.injectInheritedThemes,
                );
              },
            );
          },
        );
      },
    );
  }
}
