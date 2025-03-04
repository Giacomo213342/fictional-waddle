import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

extension OAuth2RedirectUriExtension on Client {
  Uri get oAuth2RedirectUri => Uri.parse(
        kIsWeb
            ? 'https://polycule.im/web/?action=oauth2redirect'
            : 'im.polycule:/oauth2redirect/',
      );
}
