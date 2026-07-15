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
      final fontScale = await kPolyculeSecureStorage.read(key: 'fontScale');
      return ThemeState(
        themeMode: switch (themeMode) {
          'terminal' => PolyculeTheme.terminal,
          'mySpace' => PolyculeTheme.mySpace,
          'system' || _ => PolyculeTheme.system,
        },
        colorMode: switch (colorMode) {
          'system' || null => PolyculeColorMode.system,
          'theme' => PolyculeColorMode.theme,
          'oled' => PolyculeColorMode.oled,
          'highContrast' => PolyculeColorMode.highContrast,
          _ => PolyculeColorMode.custom,
        },
        fontMode: switch (fontMode) {
          'visionLimited' => PolyculeFontMode.visionLimited,
          'dyslexic' => PolyculeFontMode.dyslexic,
          'serif' => PolyculeFontMode.serif,
          'theme' || null || _ => PolyculeFontMode.theme,
        },
        fontScale: fontScale == null ? 1 : double.tryParse(fontScale) ?? 1,
      );
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'themeMode');
      await kPolyculeSecureStorage.delete(key: 'colorMode');
      await kPolyculeSecureStorage.delete(key: 'fontMode');
      await kPolyculeSecureStorage.delete(key: 'fontScale');
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
    await kPolyculeSecureStorage.write(
      key: 'fontScale',
      value: theme.fontScale.toString(),
    );
  }

  Future<NetworkState> getNetwork() async {
    try {
      final useSni = await kPolyculeSecureStorage.read(key: 'useSni');
      final tlsMinVersion =
          await kPolyculeSecureStorage.read(key: 'tlsMinVersion');
      final verifyCertificates =
          await kPolyculeSecureStorage.read(key: 'verifyCertificates');
      final permitProxy = await kPolyculeSecureStorage.read(key: 'permitProxy');
      final useSocks5Proxy = await kPolyculeSecureStorage.read(key: 'useSocks5Proxy');
      final proxyHost = await kPolyculeSecureStorage.read(key: 'proxyHost');
      final proxyPortStr = await kPolyculeSecureStorage.read(key: 'proxyPort');
      final proxyUsername = await kPolyculeSecureStorage.read(key: 'proxyUsername');
      final proxyPassword = await kPolyculeSecureStorage.read(key: 'proxyPassword');
      return NetworkState(
        useSni: useSni == null ? true : bool.tryParse(useSni) ?? true,
        tlsMinVersion:
            tlsMinVersion == null ? 0x0303 : int.tryParse(tlsMinVersion),
        verifyCertificates: verifyCertificates == null
            ? true
            : bool.tryParse(verifyCertificates) ?? true,
        permitProxy:
            permitProxy == null ? true : bool.tryParse(permitProxy) ?? true,
        useSocks5Proxy: useSocks5Proxy == 'true',
        proxyHost: proxyHost,
        proxyPort: proxyPortStr != null ? int.tryParse(proxyPortStr) : null,
        proxyUsername: proxyUsername,
        proxyPassword: proxyPassword,
      );
    } on PlatformException catch (e, s) {
      ErrorLogger().captureStackTrace(e, s);
      await kPolyculeSecureStorage.delete(key: 'useSni');
      await kPolyculeSecureStorage.delete(key: 'tlsMinVersion');
      await kPolyculeSecureStorage.delete(key: 'verifyCertificates');
      await kPolyculeSecureStorage.delete(key: 'permitProxy');
      await kPolyculeSecureStorage.delete(key: 'useSocks5Proxy');
      await kPolyculeSecureStorage.delete(key: 'proxyHost');
      await kPolyculeSecureStorage.delete(key: 'proxyPort');
      await kPolyculeSecureStorage.delete(key: 'proxyUsername');
      await kPolyculeSecureStorage.delete(key: 'proxyPassword');
      return NetworkState();
    }
  }

  Future<void> storeNetwork(NetworkState network) async {
    await kPolyculeSecureStorage.write(
      key: 'useSni',
      value: network.useSni.toString(),
    );
    await kPolyculeSecureStorage.write(
      key: 'tlsMinVersion',
      value: network.tlsMinVersion.toString(),
    );
    await kPolyculeSecureStorage.write(
      key: 'verifyCertificates',
      value: network.verifyCertificates.toString(),
    );
    await kPolyculeSecureStorage.write(
      key: 'permitProxy',
      value: network.permitProxy.toString(),
    );
    await kPolyculeSecureStorage.write(
      key: 'useSocks5Proxy',
      value: network.useSocks5Proxy.toString(),
    );
    await kPolyculeSecureStorage.write(
      key: 'proxyHost',
      value: network.proxyHost,
    );
    await kPolyculeSecureStorage.write(
      key: 'proxyPort',
      value: network.proxyPort?.toString(),
    );
    await kPolyculeSecureStorage.write(
      key: 'proxyUsername',
      value: network.proxyUsername,
    );
    await kPolyculeSecureStorage.write(
      key: 'proxyPassword',
      value: network.proxyPassword,
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
