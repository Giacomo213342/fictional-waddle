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
        builder: (context, themeState, _) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.contrast),
              title: Text(AppLocalizations.of(context).theme),
            ),
            RadioGroup<PolyculeTheme>(
              groupValue: themeState.themeMode,
              onChanged: _setThemeMode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile.adaptive(
                    value: PolyculeTheme.system,
                    title: Text(AppLocalizations.of(context).systemTheme),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeTheme.terminal,
                    title: Text(AppLocalizations.of(context).dark),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeTheme.mySpace,
                    title: Text(AppLocalizations.of(context).light),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.colorize),
              title: Text(AppLocalizations.of(context).color),
            ),
            RadioGroup<PolyculeColorMode>(
              groupValue: themeState.colorMode,
              onChanged: _setColorMode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile.adaptive(
                    value: PolyculeColorMode.system,
                    title: Text(AppLocalizations.of(context).systemColor),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeColorMode.theme,
                    title: Text(AppLocalizations.of(context).defaultColor),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeColorMode.highContrast,
                    title: Text(AppLocalizations.of(context).highContrast),
                  ),
                  const RadioListTile.adaptive(
                    value: PolyculeColorMode.oled,
                    title: Text('OLED black'),
                    subtitle: Text('Pure black background'),
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.format_size),
              title: Text(AppLocalizations.of(context).fontSize),
              subtitle: Text(
                AppLocalizations.of(context)
                    .fontScaleLabel(themeState.fontScale),
              ),
              trailing: IconButton(
                onPressed: () => _setFontScale(1),
                icon: const Icon(Icons.refresh),
                tooltip: AppLocalizations.of(context).reset,
              ),
            ),
            Slider.adaptive(
              value: themeState.fontScale,
              onChanged: _setFontScale,
              divisions: 8,
              label: AppLocalizations.of(context)
                  .fontScaleLabel(themeState.fontScale),
              min: .75,
              max: 1.75,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.text_format),
              title: Text(AppLocalizations.of(context).fontAccessibility),
            ),
            RadioGroup<PolyculeFontMode>(
              groupValue: themeState.fontMode,
              onChanged: _setFontMode,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile.adaptive(
                    value: PolyculeFontMode.theme,
                    title: Text(AppLocalizations.of(context).defaultFont),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeFontMode.visionLimited,
                    title: Text(AppLocalizations.of(context).inclusiveSans),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeFontMode.dyslexic,
                    title: Text(AppLocalizations.of(context).openDyslexic),
                  ),
                  RadioListTile.adaptive(
                    value: PolyculeFontMode.serif,
                    title: Text(AppLocalizations.of(context).serif),
                  ),
                ],
              ),
            ),
          ],
        ),
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

    final current = SettingsManager.of(context).theme.value;
    SettingsManager.of(context).theme.value = current.copyWith(
      colorMode: colorMode,
      themeMode:
          colorMode == PolyculeColorMode.oled ? PolyculeTheme.terminal : null,
    );
  }

  void _setFontMode(PolyculeFontMode? fontMode) {
    if (fontMode == null) {
      return;
    }

    SettingsManager.of(context).theme.value =
        SettingsManager.of(context).theme.value.copyWith(fontMode: fontMode);
  }

  void _setFontScale(double value) {
    SettingsManager.of(context).theme.value =
        SettingsManager.of(context).theme.value.copyWith(fontScale: value);
  }
}
