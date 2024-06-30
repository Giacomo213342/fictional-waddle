import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';

import 'src/../l10n/generated/app_localizations.dart';
import 'src/router/router.dart';

void main(List<String>? args) {
  Logs().level = Level.verbose;
  // used to capture errors in main thread
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      MediaKit.ensureInitialized();
      JustAudioMediaKit.ensureInitialized();
      runApp(const PolyculeClient());
    },
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
            fontFamily:
                !kIsWeb && Platform.isWindows ? 'Arial' : 'GL Suetterlin',
            fontFamilyFallback: const ['Noto Color Emoji'],
            colorScheme: lightDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.pink,
                  brightness: Brightness.light,
                ),
            brightness: Brightness.light,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            fontFamily: !kIsWeb && Platform.isWindows ? 'Arial' : 'Sono',
            fontFamilyFallback: const ['Noto Color Emoji'],
            colorScheme: darkDynamic ??
                ColorScheme.fromSeed(
                  seedColor: Colors.indigo,
                  brightness: Brightness.dark,
                ),
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: ThemeMode.system,
          routerConfig: router,
        );
      },
    );
  }
}
