import 'dart:async';

import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:matrix/matrix.dart';

import 'src/../l10n/generated/app_localizations.dart';
import 'src/router/router.dart';

void main(List<String>? args) {
  Logs().level = Level.verbose;
  // used to capture errors in main thread
  runZonedGuarded(
    () => runApp(const PolyculeClient()),
    (error, stack) {
      // TODO: de-obfuscate web stack traces using source maps
      Logs().wtf('Error launching main applications', error, stack);
    },
  );
}

class PolyculeClient extends StatelessWidget {
  const PolyculeClient({super.key});

  static final router = PolyculeRouter();

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          theme: ThemeData(
            fontFamily: 'Sono',
            colorScheme: lightDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.light,
                ),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: 'Sono',
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                ),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.dark,
          routerConfig: router,
        );
      },
    );
  }
}
