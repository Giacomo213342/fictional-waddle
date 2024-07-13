import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:dynamic_color/dynamic_color.dart';

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
        final darkColorScheme = //darkDynamic ??
            ColorScheme.fromSeed(
          seedColor: PolyColors.cyan,
          brightness: Brightness.dark,
        );
        final lightColorScheme = //lightDynamic ??
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
    return ThemeData(
      fontFamily: _fontFamily(brightness),
      fontFamilyFallback: const ['Noto Color Emoji'],
      colorScheme: colorScheme,
      cardTheme: CardTheme(
        margin: const EdgeInsets.all(16),
        shape: Border.all(width: 1, color: colorScheme.primary),
      ),
      brightness: brightness,
      useMaterial3: true,
    );
  }

  String _fontFamily(Brightness brightness) {
    if (!kIsWeb && Platform.isWindows) {
      return 'Arial';
    }
    switch (brightness) {
      case Brightness.dark:
        return 'Sono';
      case Brightness.light:
        return 'GL Suetterlin';
    }
  }
}
