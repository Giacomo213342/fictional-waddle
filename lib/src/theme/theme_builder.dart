import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';

import 'fonts.dart';
import 'poly_colors.dart';

typedef PolyculeThemeCallback = Widget Function(
  ThemeMode mode,
  ThemeData dark,
  ThemeData light,
);

class PolyculeThemeBuilder extends StatelessWidget {
  const PolyculeThemeBuilder({super.key, required this.builder});

  final PolyculeThemeCallback builder;

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final darkColorScheme = darkDynamic ??
            ColorScheme.fromSeed(
              seedColor: PolyColors.cyan,
              brightness: Brightness.dark,
            );
        final lightColorScheme = lightDynamic ??
            ColorScheme.fromSeed(
              seedColor: PolyColors.pink,
              brightness: Brightness.light,
            );

        final dark = buildPolyculeTheme(
          colorScheme: darkColorScheme,
          brightness: Brightness.dark,
        );
        final light = buildPolyculeTheme(
          colorScheme: lightColorScheme,
          brightness: Brightness.light,
        );
        // TODO: support manual theme setting
        const mode = ThemeMode.system;

        return builder.call(mode, dark, light);
      },
    );
  }

  ThemeData buildPolyculeTheme({
    required ColorScheme colorScheme,
    required Brightness brightness,
  }) {
    final defaultSide = BorderSide(width: 1, color: colorScheme.primary);
    final defaultBorder = Border.fromBorderSide(defaultSide);
    return ThemeData(
      fontFamily: _fontFamily(brightness).name,
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

  PolyculeFonts _fontFamily(Brightness brightness) {
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
