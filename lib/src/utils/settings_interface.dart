import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/theme_modes.dart';
import '../widgets/settings_manager.dart';
import 'error_logger.dart';
import 'secure_storage.dart';

class SettingsInterface {
  const SettingsInterface();

  Future<ThemeState> getTheme() async {
    try {
      final themeMode = await kPolyculeSecureStorage.read(key: 'themeMode');
      final colorMode = await kPolyculeSecureStorage.read(key: 'colorMode');
      final fontMode = await kPolyculeSecureStorage.read(key: 'fontMode');
      return ThemeState(
        themeMode: switch (themeMode) {
          'terminal' => PolyculeTheme.terminal,
          'mySpace' => PolyculeTheme.mySpace,
          'system' || _ => PolyculeTheme.system,
        },
        colorMode: switch (colorMode) {
          'system' || null => PolyculeColorMode.system,
          'theme' => PolyculeColorMode.theme,
          _ => PolyculeColorMode.custom,
        },
        fontMode: switch (fontMode) {
          'visionLimited' => PolyculeFontMode.visionLimited,
          'dyslexic' => PolyculeFontMode.dyslexic,
          'serif' => PolyculeFontMode.serif,
          'theme' || null || _ => PolyculeFontMode.theme,
        },
      );
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'themeMode');
      await kPolyculeSecureStorage.delete(key: 'colorMode');
      await kPolyculeSecureStorage.delete(key: 'fontMode');
      return ThemeState();
    }
  }

  Future<void> storeTheme(ThemeState theme) async {
    await kPolyculeSecureStorage.write(
      key: 'themeMode',
      value: theme.themeMode.name,
    );
    await kPolyculeSecureStorage.write(
      key: 'colorMode',
      value: theme.colorMode.name,
    );
    await kPolyculeSecureStorage.write(
      key: 'fontMode',
      value: theme.fontMode.name,
    );
  }

  Future<Locale?> getLocale() async {
    String? storedLocale;
    try {
      storedLocale = await kPolyculeSecureStorage.read(key: 'locale');
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
    }
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
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'locale');
      return null;
    } catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      return null;
    }
  }

  Future<void> storeLocale(Locale? locale) {
    return kPolyculeSecureStorage.write(
      key: 'locale',
      value: locale?.toLanguageTag(),
    );
  }

  Future<String?> getPushDistributor() async {
    try {
      return kPolyculeSecureStorage.read(key: 'push_distributor');
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'push_distributor');
      return null;
    }
  }

  Future<void> storePushDistributor(String? distributor) async {
    return kPolyculeSecureStorage.write(
      key: 'push_distributor',
      value: distributor,
    );
  }

  Future<bool> getSentryEnabled() async {
    try {
      final storedSentry =
          await kPolyculeSecureStorage.read(key: 'sentry_enabled');
      if (storedSentry == null) {
        return false;
      }
      return bool.tryParse(storedSentry) ?? false;
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'sentry_enabled');
      return false;
    }
  }

  Future<void> storeSentryEnabled(bool enabled) async {
    return kPolyculeSecureStorage.write(
      key: 'sentry_enabled',
      value: enabled.toString(),
    );
  }

  Future<String?> getPushKey(String clientName) async {
    try {
      return kPolyculeSecureStorage.read(key: 'push_key_$clientName');
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'push_key_$clientName');
      return null;
    }
  }

  Future<void> storePushKey(String clientName, String endpoint) async {
    return kPolyculeSecureStorage.write(
      key: 'push_key_$clientName',
      value: endpoint,
    );
  }
}
