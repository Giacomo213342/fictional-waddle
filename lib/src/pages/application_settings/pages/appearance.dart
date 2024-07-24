import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme_modes.dart';
import '../../../widgets/settings_manager.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  static const routeName = 'appearance';

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppLocalizations.of(context).appearanceAccessibilitySettings),
      ),
      body: ValueListenableBuilder<ThemeState>(
        valueListenable: SettingsManager.of(context).theme,
        builder: (context, themeState, _) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.contrast),
                title: Text(AppLocalizations.of(context).theme),
              ),
              RadioListTile.adaptive(
                value: PolyculeTheme.system,
                groupValue: themeState.themeMode,
                title: Text(AppLocalizations.of(context).systemTheme),
                onChanged: _setThemeMode,
              ),
              RadioListTile.adaptive(
                value: PolyculeTheme.terminal,
                groupValue: themeState.themeMode,
                title: Text(AppLocalizations.of(context).dark),
                onChanged: _setThemeMode,
              ),
              RadioListTile.adaptive(
                value: PolyculeTheme.mySpace,
                groupValue: themeState.themeMode,
                title: Text(AppLocalizations.of(context).light),
                onChanged: _setThemeMode,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.colorize),
                title: Text(AppLocalizations.of(context).color),
              ),
              RadioListTile.adaptive(
                value: PolyculeColorMode.system,
                groupValue: themeState.colorMode,
                title: Text(AppLocalizations.of(context).systemColor),
                onChanged: _setColorMode,
              ),
              RadioListTile.adaptive(
                value: PolyculeColorMode.theme,
                groupValue: themeState.colorMode,
                title: Text(AppLocalizations.of(context).defaultColor),
                onChanged: _setColorMode,
              ),
              RadioListTile.adaptive(
                value: PolyculeColorMode.highContrast,
                groupValue: themeState.colorMode,
                title: Text(AppLocalizations.of(context).highContrast),
                onChanged: _setColorMode,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.text_format),
                title: Text(AppLocalizations.of(context).fontAccessibility),
              ),
              RadioListTile.adaptive(
                value: PolyculeFontMode.theme,
                groupValue: themeState.fontMode,
                title: Text(AppLocalizations.of(context).defaultFont),
                onChanged: _setFontMode,
              ),
              RadioListTile.adaptive(
                value: PolyculeFontMode.visionLimited,
                groupValue: themeState.fontMode,
                title: Text(AppLocalizations.of(context).inclusiveSans),
                onChanged: _setFontMode,
              ),
              RadioListTile.adaptive(
                value: PolyculeFontMode.dyslexic,
                groupValue: themeState.fontMode,
                title: Text(AppLocalizations.of(context).openDyslexic),
                onChanged: _setFontMode,
              ),
            ],
          );
        },
      ),
    );
  }

  void _setThemeMode(PolyculeTheme? theme) {
    if (theme == null) {
      return;
    }

    SettingsManager.of(context).theme.value =
        SettingsManager.of(context).theme.value.copyWith(themeMode: theme);
  }

  void _setColorMode(PolyculeColorMode? colorMode) {
    if (colorMode == null) {
      return;
    }

    SettingsManager.of(context).theme.value =
        SettingsManager.of(context).theme.value.copyWith(colorMode: colorMode);
  }

  void _setFontMode(PolyculeFontMode? fontMode) {
    if (fontMode == null) {
      return;
    }

    SettingsManager.of(context).theme.value =
        SettingsManager.of(context).theme.value.copyWith(fontMode: fontMode);
  }
}
