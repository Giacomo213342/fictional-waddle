import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

import 'oidc_delegation_extension.dart';

extension OAuth2RedirectUriExtension on Client {
  Uri get oAuth2RedirectUri => kIsWeb
      ? PolyculeOidcDynamicClientRegistrationData.oidcClientOrigin
      : Uri.parse('im.polycule:/oauth2redirect/');
}
