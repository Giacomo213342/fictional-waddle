import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'router/router.dart';
import 'theme/theme_builder.dart';

class PolyculeClient extends StatelessWidget {
  const PolyculeClient({super.key});

  static final router = PolyculeRouter();

  @override
  Widget build(BuildContext context) {
    return PolyculeThemeBuilder(
      builder: (mode, dark, light) {
        return MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          theme: light,
          darkTheme: dark,
          themeMode: mode,
          routerConfig: router,
        );
      },
    );
  }
}
