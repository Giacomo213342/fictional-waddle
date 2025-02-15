import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

import '../generated/app_localizations.dart';

extension PolyculeMatrixLocalizationsExtension on AppLocalizations {
  PolyculeMatrixLocalizations get matrix => PolyculeMatrixLocalizations(this);

  LocalizedOidcClientMetadata get oidc => LocalizedOidcClientMetadata(
        clientName: oidcAppName,
        logo: Uri.parse(oidcLogoUrl),
        tos: Uri.parse(oidcTosUrl),
        policy: Uri.parse(oicPolicyUri),
      );

  String get initialDeviceDisplayName {
    if (kIsWeb) {
      return clientDisplayName(platformWeb);
    }
    if (Platform.isIOS || Platform.isAndroid) {
      return clientDisplayName(Platform.operatingSystem);
    }
    return clientDisplayNameHostname(
      Platform.localHostname,
      Platform.operatingSystem,
    );
  }
}

class PolyculeMatrixLocalizations extends MatrixDefaultLocalizations {
  const PolyculeMatrixLocalizations(this.l10n);

  final AppLocalizations l10n;
}
