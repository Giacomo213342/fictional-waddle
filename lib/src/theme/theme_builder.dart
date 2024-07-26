import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../widgets/placeholder.dart';
import '../widgets/settings_manager.dart';
import 'fonts.dart';
import 'poly_colors.dart';
import 'theme_modes.dart';

typedef PolyculeThemeCallback = Widget Function(
  ThemeMode mode,
  ThemeData dark,
  ThemeData light,
);

class PolyculeThemeBuilder extends StatelessWidget {
  const PolyculeThemeBuilder({super.key, required this.builder});

  static Widget injectInheritedThemes(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    return MaterialDesktopVideoControlsTheme(
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
    );
  }

  final PolyculeThemeCallback builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeState>(
      valueListenable: SettingsManager.of(context).theme,
      builder: (context, themeState, _) => DynamicColorBuilder(
        builder: (lightDynamic, darkDynamic) {
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

          final dark = buildPolyculeTheme(
            colorScheme: darkColorScheme,
            brightness: Brightness.dark,
            themeState: themeState,
          );
          final light = buildPolyculeTheme(
            colorScheme: lightColorScheme,
            brightness: Brightness.light,
            themeState: themeState,
          );
          final mode = themeState.themeMode.toThemeMode();

          return builder.call(mode, dark, light);
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
      cardTheme: CardTheme(
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

        switch (brightness) {
          case Brightness.dark:
            return PolyculeFonts.sono;
          case Brightness.light:
            return PolyculeFonts.glSuetterlin;
        }
    }
  }
}
