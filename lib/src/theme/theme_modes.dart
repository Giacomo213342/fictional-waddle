import 'package:flutter/material.dart';

enum PolyculeTheme {
  system,
  terminal,
  mySpace,
}

extension SystemTheme on PolyculeTheme {
  ThemeMode toThemeMode() {
    switch (this) {
      case PolyculeTheme.system:
        return ThemeMode.system;
      case PolyculeTheme.terminal:
        return ThemeMode.dark;
      case PolyculeTheme.mySpace:
        return ThemeMode.light;
    }
  }
}

enum PolyculeColorMode {
  system,
  theme,
  highContrast,
  oled,
  custom,
}

enum PolyculeFontMode {
  theme,
  visionLimited,
  dyslexic,
  serif,
}
