import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../widgets/placeholder.dart';
import '../widgets/settings_manager.dart';
import 'colors/poly_pride.dart';
import 'fonts.dart';
import 'theme_modes.dart';

typedef PolyculeThemeConfigCallback = Widget Function(
  BuildContext context,
  PolyculeThemeConfig themeConfig,
);

class PolyculeThemeConfig {
  const PolyculeThemeConfig({
    required this.themeMode,
    required this.dark,
    required this.light,
    required this.preferHighContrast,
  });

  final ThemeMode themeMode;

  final PolyculeThemeMode dark;
  final PolyculeThemeMode light;

  final bool preferHighContrast;
}

class PolyculeThemeMode {
  const PolyculeThemeMode({required this.main, required this.highContrast});

  final ThemeData main;
  final ThemeData highContrast;
}

class PolyculeThemeBuilder extends StatelessWidget {
  const PolyculeThemeBuilder({super.key, required this.builder});

  static Widget injectInheritedThemes(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return ValueListenableBuilder<ThemeState>(
      valueListenable: SettingsManager.of(context).theme,
      builder: (context, value, child) => MediaQuery(
        data: mediaQuery.copyWith(
          textScaler: TextScaler.linear(
            // scale some reference and divide it once again by the reference
            (mediaQuery.textScaler.scale(11) * value.fontScale) / 11,
          ),
        ),
        child: child ?? const PolyculePlaceholder(),
      ),
      child: MaterialDesktopVideoControlsTheme(
        normal: MaterialDesktopVideoControlsThemeData(
          seekBarPositionColor: theme.colorScheme.primary,
          seekBarThumbColor: theme.colorScheme.primary,
        ),
        fullscreen: MaterialDesktopVideoControlsThemeData(
          seekBarPositionColor: theme.colorScheme.primary,
          seekBarThumbColor: theme.colorScheme.primary,
        ),
        child: MaterialVideoControlsTheme(
          normal: MaterialVideoControlsThemeData(
            seekBarPositionColor: theme.colorScheme.primary,
            seekBarThumbColor: theme.colorScheme.primary,
          ),
          fullscreen: MaterialVideoControlsThemeData(
            seekBarPositionColor: theme.colorScheme.primary,
            seekBarThumbColor: theme.colorScheme.primary,
          ),
          child: child ?? const PolyculePlaceholder(),
        ),
      ),
    );
  }

  final PolyculeThemeConfigCallback builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeState>(
      valueListenable: SettingsManager.of(context).theme,
      builder: (context, themeState, _) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
          final preferHighContrast =
              themeState.colorMode == PolyculeColorMode.highContrast ||
                  MediaQuery.of(context).highContrast;

          final darkFallback = ColorScheme.fromSeed(
            seedColor: PolyColors.cyan,
            brightness: Brightness.dark,
          );

          final darkColorScheme =
              themeState.colorMode == PolyculeColorMode.system
                  ? darkDynamic ?? darkFallback
                  : darkFallback;

          final lightFallback = ColorScheme.fromSeed(
            seedColor: PolyColors.pink,
            brightness: Brightness.light,
          );

          final lightColorScheme =
              themeState.colorMode == PolyculeColorMode.system
                  ? lightDynamic ?? lightFallback
                  : lightFallback;

          final config = PolyculeThemeConfig(
            themeMode: themeState.themeMode.toThemeMode(),
            dark: PolyculeThemeMode(
              main: buildPolyculeTheme(
                colorScheme: darkColorScheme,
                brightness: Brightness.dark,
                themeState: themeState,
              ),
              highContrast: buildPolyculeTheme(
                colorScheme: const ColorScheme.highContrastDark(),
                brightness: Brightness.dark,
                themeState: themeState,
              ),
            ),
            light: PolyculeThemeMode(
              main: buildPolyculeTheme(
                colorScheme: lightColorScheme,
                brightness: Brightness.light,
                themeState: themeState,
              ),
              highContrast: buildPolyculeTheme(
                colorScheme: const ColorScheme.highContrastLight(),
                brightness: Brightness.light,
                themeState: themeState,
              ),
            ),
            preferHighContrast: preferHighContrast,
          );

          return builder.call(context, config);
        },
      ),
    );
  }

  ThemeData buildPolyculeTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required ThemeState themeState,
  }) {
    final defaultSide = BorderSide(width: 1, color: colorScheme.primary);
    final defaultBorder = Border.fromBorderSide(defaultSide);
    return ThemeData(
      fontFamily: _fontFamily(brightness, themeState.fontMode).name,
      fontFamilyFallback: [
        PolyculeFonts.notoColorEmoji.name,
        PolyculeFonts.notoSans.name,
      ],
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        margin: const EdgeInsets.all(16),
        shape: defaultBorder,
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll<Color>(colorScheme.surface),
        shape: WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(
            side: defaultSide,
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
      searchViewTheme: const SearchViewThemeData(
        shape: RoundedRectangleBorder(),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
      ),
      brightness: brightness,
      useMaterial3: true,
    );
  }

  PolyculeFonts _fontFamily(Brightness brightness, PolyculeFontMode fontMode) {
    switch (fontMode) {
      case PolyculeFontMode.visionLimited:
        return PolyculeFonts.inclusiveSans;
      case PolyculeFontMode.dyslexic:
        return PolyculeFonts.openDyslexic;
      default:
        if (!kIsWeb && Platform.isWindows) {
          return PolyculeFonts.arial;
        }
        if (fontMode == PolyculeFontMode.serif) {
          return PolyculeFonts.vollkorn;
        }

        switch (brightness) {
          case Brightness.dark:
            return PolyculeFonts.overpassMono;
          case Brightness.light:
            return PolyculeFonts.marckScript;
        }
    }
  }
}
