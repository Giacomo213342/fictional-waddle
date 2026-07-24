import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import 'router/router.dart';
import 'theme/theme_builder.dart';
import 'utils/matrix/push_manager.dart';
import 'widgets/intent_manager.dart';
import 'widgets/matrix/client_manager/client_manager.dart';
import 'widgets/settings_manager.dart';

class PolyculeClient extends StatefulWidget {
  const PolyculeClient({super.key});

  @override
  State<PolyculeClient> createState() => _PolyculeClientState();
}

class _PolyculeClientState extends State<PolyculeClient>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(PushManager.dismissBackgroundFallbackNotifications());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(PushManager.dismissBackgroundFallbackNotifications());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SettingsBuilder(
        builder: (context) => const ClientManagerRoot(
          child: PolyculeRouterClientProvider(),
        ),
      );
}

/// injects the currently active [ClientStore.activeClients] into the router
/// to create a [StatefulShellRoute]
class PolyculeRouterClientProvider extends StatelessWidget {
  const PolyculeRouterClientProvider({super.key});

  static PolyculeRouter? router;

  @override
  Widget build(BuildContext context) {
    router ??= PolyculeRouter(ClientManager.of(context).store.activeClients);
    IntentManager.attachNavigation(router!.go);
    return SettingsBuilder(
      builder: (context) => PolyculeThemeBuilder(
        builder: (context, config) => ValueListenableBuilder<Locale?>(
          valueListenable: SettingsManager.of(context).locale,
          builder: (context, locale, _) => MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateTitle: (context) => AppLocalizations.of(context).appName,
            locale: locale,
            theme: config.preferHighContrast
                ? config.light.highContrast
                : config.light.main,
            darkTheme: config.preferHighContrast
                ? config.dark.highContrast
                : config.dark.main,
            highContrastDarkTheme: config.dark.highContrast,
            highContrastTheme: config.light.highContrast,
            themeMode: config.themeMode,
            routerConfig: router,
            builder: PolyculeThemeBuilder.injectInheritedThemes,
          ),
        ),
      ),
    );
  }
}
