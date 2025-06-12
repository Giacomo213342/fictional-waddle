import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:polycule/l10n/generated/app_localizations.dart';
import 'package:polycule/l10n/matrix/polycule_matrix_localizations.dart';

void main() {
  group('OIDC client metadata', () {
    late AppLocalizations defaultLocale;
    setUpAll(() async {
      // we use English as fallback locale
      defaultLocale = await AppLocalizations.delegate.load(const Locale('en'));
    });
    test(
      'web location origin localhost',
      () {
        final origin = Uri.parse('http://localhost:12345').resolve('/');

        final oidcLocale = defaultLocale.oidcClientMetadata(origin);

        expect(
          oidcLocale.logo,
          Uri.parse(
            'http://localhost:12345/assets/assets/logo/logo-circle.png',
          ),
        );
        expect(
          oidcLocale.tos,
          Uri.parse('http://localhost:12345/tos.html'),
        );
        expect(
          oidcLocale.policy,
          Uri.parse('http://localhost:12345/policy.html'),
        );

        final redirect = origin.resolve('?action=oauth2redirect');
        expect(
          redirect,
          Uri.parse('http://localhost:12345/?action=oauth2redirect'),
        );
      },
      tags: 'oidc',
    );
    test(
      'web location origin polycule.im',
      () {
        final origin = Uri.parse('https://polycule.im').resolve('/web/');
        final oidcLocale = defaultLocale.oidcClientMetadata(origin);

        expect(
          oidcLocale.logo,
          Uri.parse(
            'https://polycule.im/web/assets/assets/logo/logo-circle.png',
          ),
        );
        expect(
          oidcLocale.tos,
          Uri.parse('https://polycule.im/web/tos.html'),
        );
        expect(
          oidcLocale.policy,
          Uri.parse('https://polycule.im/web/policy.html'),
        );

        final redirect = origin.resolve('?action=oauth2redirect');
        expect(
          redirect,
          Uri.parse('https://polycule.im/web/?action=oauth2redirect'),
        );
      },
      tags: 'oidc',
    );
    test(
      'web location origin polycule.im no trailing slash',
      () {
        final origin = Uri.parse('https://polycule.im').resolve('/web');
        final oidcLocale = defaultLocale.oidcClientMetadata(origin);

        expect(
          oidcLocale.logo,
          Uri.parse(
            'https://polycule.im/assets/assets/logo/logo-circle.png',
          ),
        );
        expect(
          oidcLocale.tos,
          Uri.parse('https://polycule.im/tos.html'),
        );
        expect(
          oidcLocale.policy,
          Uri.parse('https://polycule.im/policy.html'),
        );

        final redirect = origin.resolve('?action=oauth2redirect');
        expect(
          redirect,
          Uri.parse('https://polycule.im/web?action=oauth2redirect'),
        );
      },
      tags: 'oidc',
    );
    test(
      'web location origin polycule.example.com',
      () {
        final origin = Uri.parse('https://polycule.example.com').resolve('/');
        final oidcLocale = defaultLocale.oidcClientMetadata(origin);

        expect(
          oidcLocale.logo,
          Uri.parse(
            'https://polycule.example.com/assets/assets/logo/logo-circle.png',
          ),
        );
        expect(
          oidcLocale.tos,
          Uri.parse('https://polycule.example.com/tos.html'),
        );
        expect(
          oidcLocale.policy,
          Uri.parse('https://polycule.example.com/policy.html'),
        );

        final redirect = origin.resolve('?action=oauth2redirect');
        expect(
          redirect,
          Uri.parse('https://polycule.example.com/?action=oauth2redirect'),
        );
      },
      tags: 'oidc',
    );
  });
}
