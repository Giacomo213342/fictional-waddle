import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';

abstract class PolyculeOidcDynamicClientRegistrationData {
  const PolyculeOidcDynamicClientRegistrationData._();

  static Future<OidcDynamicRegistrationData> fromAppLocalizations() async {
    // we use English as fallback locale
    final defaultLocale =
        await AppLocalizations.delegate.load(const Locale('en'));
    final defaultOidcLocale = defaultLocale.oidc;

    final localizations = Map.fromEntries(
      await Future.wait(
        AppLocalizations.supportedLocales.map(
          (locale) => AppLocalizations.delegate.load(locale).then(
                (localizations) => MapEntry(
                  _oidcLocaleName(locale),
                  localizations.oidc,
                ),
              ),
        ),
      ),
    );

    return OidcDynamicRegistrationData.localized(
      contacts: {defaultLocale.oidcContact},
      url: Uri.parse(defaultLocale.oidcAppUrl),
      defaultLocale: defaultOidcLocale,
      localizations: localizations,
      redirect: kIsWeb
          ? {Uri.parse('https://polycule.im/web/?action=oauth2redirect')}
          : {
              // not my fault *grumble*
              // https://github.com/element-hq/matrix-authentication-service/blob/main/crates/handlers/src/oauth2/registration.rs#L179
              Uri.parse('im.polycule:/oauth2redirect/'),
              Uri.parse('http://localhost/oauth2redirect/'),
            },
      applicationType: kIsWeb ? 'web' : 'native',
    );
  }

  static String _oidcLocaleName(Locale locale) => locale.countryCode == null
      ? locale.languageCode.toLowerCase()
      : r'#' +
          locale.languageCode.toLowerCase() +
          r'-' +
          locale.countryCode!.toUpperCase();
}
