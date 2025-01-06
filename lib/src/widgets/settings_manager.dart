// ignore_for_file:implementation_imports

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:rhttp/src/rust/api/client.dart' show TlsVersion;

import '../theme/theme_modes.dart';
import '../utils/error_logger.dart';
import '../utils/settings_interface.dart';

class SettingsBuilder extends StatelessWidget {
  const SettingsBuilder({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) =>
      SettingsManager(child: Builder(builder: builder));
}

class SettingsManager extends InheritedWidget {
  SettingsManager({super.key, required super.child}) {
    unawaited(initSettings());
  }

  final _settingsInterface = const SettingsInterface();
  final initCompleter = Completer<void>();

  Future<void> initSettings() async {
    if (initCompleter.isCompleted) {
      return;
    }
    final storedTheme = await _settingsInterface.getTheme();
    theme.value = storedTheme;
    theme.addListener(_storeTheme);

    final storedNetwork = await _settingsInterface.getNetwork();
    network.value = storedNetwork;
    network.addListener(_storeNetwork);

    final storedLocale = await _settingsInterface.getLocale();
    locale.value = storedLocale;
    locale.addListener(_storeLocale);

    final storedPushDistributor = await _settingsInterface.getPushDistributor();
    pushDistributor.value = storedPushDistributor;
    pushDistributor.addListener(_storePushDistributor);

    final storedSentryEnabled = await _settingsInterface.getSentryEnabled();
    sentryEnabled.value = storedSentryEnabled;

    ErrorLogger().sentryEnabled = storedSentryEnabled;
    if (!ErrorLogger().initializer.isCompleted) {
      ErrorLogger().initializer.complete();
    }
    sentryEnabled.addListener(_storeSentryEnabled);

    initCompleter.complete();
  }

  final theme = ValueNotifier(ThemeState());
  final network = ValueNotifier(NetworkState());
  final locale = ValueNotifier<Locale?>(null);
  final pushDistributor = ValueNotifier<String?>(null);
  final sentryEnabled = ValueNotifier<bool>(false);

  static SettingsManager? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SettingsManager>();
  }

  static SettingsManager of(BuildContext context) {
    final SettingsManager? result = maybeOf(context);
    assert(result != null, 'No SettingsManager found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant SettingsManager oldWidget) =>
      theme.value != oldWidget.theme.value;

  Future<void> _storeTheme() async {
    await _settingsInterface.storeTheme(theme.value);
  }

  Future<void> _storeNetwork() async {
    await _settingsInterface.storeNetwork(network.value);
  }

  Future<void> _storeLocale() async {
    await _settingsInterface.storeLocale(locale.value);
  }

  Future<void> _storePushDistributor() async {
    await _settingsInterface.storePushDistributor(pushDistributor.value);
  }

  Future<void> _storeSentryEnabled() async {
    ErrorLogger().sentryEnabled = sentryEnabled.value;
    await _settingsInterface.storeSentryEnabled(sentryEnabled.value);
  }
}

class ThemeState {
  ThemeState({
    this.themeMode = PolyculeTheme.system,
    this.colorMode = PolyculeColorMode.system,
    this.fontMode = PolyculeFontMode.theme,
    this.fontScale = 1,
  });

  final PolyculeTheme themeMode;
  final PolyculeColorMode colorMode;
  final PolyculeFontMode fontMode;
  final double fontScale;

  ThemeState copyWith({
    PolyculeTheme? themeMode,
    PolyculeColorMode? colorMode,
    PolyculeFontMode? fontMode,
    double? fontScale,
  }) =>
      ThemeState(
        themeMode: themeMode ?? this.themeMode,
        colorMode: colorMode ?? this.colorMode,
        fontMode: fontMode ?? this.fontMode,
        fontScale: fontScale ?? this.fontScale,
      );

  @override
  int get hashCode =>
      themeMode.hashCode ^
      colorMode.hashCode ^
      fontMode.hashCode ^
      fontScale.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is ThemeState) {
      return themeMode == other.themeMode &&
          colorMode == other.colorMode &&
          fontMode == other.fontMode &&
          fontScale == other.fontScale;
    }
    return super == other;
  }
}

class NetworkState {
  NetworkState({
    this.useSni = true,
    this.tlsMinVersion,
    this.verifyCertificates = true,
    this.permitProxy = true,
  });

  final bool useSni;
  final TlsVersion? tlsMinVersion;
  final bool verifyCertificates;
  final bool permitProxy;

  NetworkState copyWith({
    bool? useSni,
    TlsVersion? tlsMinVersion,
    bool? verifyCertificates,
    bool? permitProxy,
  }) =>
      NetworkState(
        useSni: useSni ?? this.useSni,
        tlsMinVersion: tlsMinVersion ?? this.tlsMinVersion,
        verifyCertificates: verifyCertificates ?? this.verifyCertificates,
        permitProxy: permitProxy ?? this.permitProxy,
      );

  @override
  int get hashCode =>
      useSni.hashCode ^
      tlsMinVersion.hashCode ^
      verifyCertificates.hashCode ^
      permitProxy.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is NetworkState) {
      return useSni == other.useSni &&
          tlsMinVersion == other.tlsMinVersion &&
          verifyCertificates == other.verifyCertificates &&
          permitProxy == other.permitProxy;
    }
    return super == other;
  }
}
