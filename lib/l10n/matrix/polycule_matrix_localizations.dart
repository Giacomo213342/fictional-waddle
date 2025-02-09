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
}

class PolyculeMatrixLocalizations extends MatrixDefaultLocalizations {
  const PolyculeMatrixLocalizations(this.l10n);

  final AppLocalizations l10n;
}
