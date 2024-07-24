import 'package:flutter/material.dart';

import 'package:locale_names/locale_names.dart';

import '../../../../l10n/generated/app_localizations.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).language),
      children: [
        SimpleDialogOption(
          child: Text(
            AppLocalizations.of(context).systemLanguage,
          ),
          onPressed: () => Navigator.of(context).pop(
            const LocaleResponse(null),
          ),
        ),
        ...AppLocalizations.supportedLocales.map(
          (locale) => _LocaleOption(locale),
        ),
      ],
    );
  }
}

class _LocaleOption extends StatelessWidget {
  const _LocaleOption(this.locale);

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return SimpleDialogOption(
      child: Text(
        '${locale.nativeDisplayLanguageScript} '
        '(${locale.displayLanguageScriptIn(Localizations.localeOf(context))})',
      ),
      onPressed: () => Navigator.of(context).pop(LocaleResponse(locale)),
    );
  }
}

class LocaleResponse {
  const LocaleResponse(this.locale);

  final Locale? locale;
}
