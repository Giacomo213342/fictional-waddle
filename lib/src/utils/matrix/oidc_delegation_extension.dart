import 'dart:ui' hide window;

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../dart_environment.dart';
import '../oauth2_web/oauth2.dart';

abstract class PolyculeOidcDynamicClientRegistrationData {
  const PolyculeOidcDynamicClientRegistrationData._();

  static Uri get oidcClientOrigin {
    // when on web and on a production deployment, use the current web app uri,
    // otherwise use the provided hosted polycule uri
    return isWebHostedOrigin
        ? webHostedOrigin
        : Uri.parse(DartEnvironment.appOrigin);
  }

  static Future<OidcDynamicRegistrationData> fromAppLocalizations() async {
    // we use English as fallback locale
    final defaultLocale =
        await AppLocalizations.delegate.load(const Locale('en'));

    final origin = oidcClientOrigin;

    final defaultOidcLocale = defaultLocale.oidcClientMetadata(origin);

    final localizations = Map.fromEntries(
      await Future.wait(
        AppLocalizations.supportedLocales.map(
          (locale) => AppLocalizations.delegate.load(locale).then(
                (localizations) => MapEntry(
                  _oidcLocaleName(locale),
                  localizations.oidcClientMetadata(origin),
                ),
              ),
        ),
      ),
    );

    return OidcDynamicRegistrationData.localized(
      contacts: {defaultLocale.oidcContact},
      url: origin,
      defaultLocale: defaultOidcLocale,
      localizations: localizations,
      redirect: kIsWeb
          ? {origin}
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
      : locale.languageCode.toLowerCase() +
          r'-' +
          locale.countryCode!.toUpperCase();
}
