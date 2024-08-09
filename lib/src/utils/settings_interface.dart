import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../theme/theme_modes.dart';
import '../widgets/settings_manager.dart';
import 'secure_storage.dart';

class SettingsInterface {
  const SettingsInterface();

  Future<ThemeState> getTheme() async {
    final storage = await kPolyculeSecureStorage.readAll();
    return ThemeState(
      themeMode: switch (storage['themeMode']) {
        'terminal' => PolyculeTheme.terminal,
        'mySpace' => PolyculeTheme.mySpace,
        'system' || _ => PolyculeTheme.system,
      },
      colorMode: switch (storage['colorMode']) {
        'system' || null => PolyculeColorMode.system,
        'theme' => PolyculeColorMode.theme,
        _ => PolyculeColorMode.custom,
      },
      fontMode: switch (storage['fontMode']) {
        'visionLimited' => PolyculeFontMode.visionLimited,
        'dyslexic' => PolyculeFontMode.dyslexic,
        'serif' => PolyculeFontMode.serif,
        'theme' || null || _ => PolyculeFontMode.theme,
      },
    );
  }

  Future<void> storeTheme(ThemeState theme) {
    return Future.wait(
      [
        kPolyculeSecureStorage.write(
          key: 'themeMode',
          value: theme.themeMode.name,
        ),
        kPolyculeSecureStorage.write(
          key: 'colorMode',
          value: theme.colorMode.name,
        ),
        kPolyculeSecureStorage.write(
          key: 'fontMode',
          value: theme.fontMode.name,
        ),
      ],
    );
  }

  Future<Locale?> getLocale() async {
    final storedLocale = await kPolyculeSecureStorage.read(key: 'locale');
    if (storedLocale == null) {
      return null;
    }
    final split = storedLocale.split('-');

    // scriptCode included
    try {
      switch (split.length) {
        case 3:
          return Locale.fromSubtags(
            languageCode: split[0],
            countryCode: split[2],
            scriptCode: split[1],
          );
        case 2:
          return Locale.fromSubtags(
            languageCode: split[0],
            countryCode: split[1],
          );
        default:
          return Locale.fromSubtags(
            languageCode: split[0],
          );
      }
    } catch (e, s) {
      Logs().e('Error loading locale', e, s);
      return null;
    }
  }

  Future<void> storeLocale(Locale? locale) {
    return kPolyculeSecureStorage.write(
      key: 'locale',
      value: locale?.toLanguageTag(),
    );
  }
}
