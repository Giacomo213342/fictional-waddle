import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'router/router.dart';
import 'theme/theme_builder.dart';
import 'widgets/matrix/client_manager/client_manager.dart';
import 'widgets/settings_manager.dart';

class PolyculeClient extends StatelessWidget {
  const PolyculeClient({super.key});

  static final _router = PolyculeRouter();

  @override
  Widget build(BuildContext context) => ClientManagerRoot(
        child: SettingsBuilder(
          builder: (context) => PolyculeThemeBuilder(
            builder: (context, config) => ValueListenableBuilder<Locale?>(
              valueListenable: SettingsManager.of(context).locale,
              builder: (context, locale, _) => MaterialApp.router(
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                onGenerateTitle: (context) =>
                    AppLocalizations.of(context).appName,
                locale: locale,
                theme: config.preferHighContrast
                    ? config.light.highContrast
                    : config.light.main,
                darkTheme: config.preferHighContrast
                    ? config.dark.highContrast
                    : config.dark.main,
                highContrastDarkTheme: config.dark.highContrast,
                highContrastTheme: config.light.highContrast,
                themeMode: config.themeMode,
                routerConfig: _router,
                builder: PolyculeThemeBuilder.injectInheritedThemes,
              ),
            ),
          ),
        ),
      );
}
