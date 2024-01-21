import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => '< polycule >';

  @override
  String get about => 'About';

  @override
  String author(String author) {
    return 'Author: $author';
  }

  @override
  String get appSlogan =>
      'A simple and beautiful matrix client written in Flutter.';

  @override
  String get repoLabel => 'Source code (GitLab)';

  @override
  String get releaseNotes => 'Release notes';

  @override
  String get buyMeACoffee => 'Buy me a coffee';

  @override
  String get homeserverHeadline => 'Haj ! Welcome to < polycule >';

  @override
  String get aMatrixClient => '- yet another [matrix] client';

  @override
  String get connectToHomeserver => 'Connect to your homeserver';

  @override
  String get discoverHomeservers => 'Discover new homeservers';

  @override
  String get newToMatrixLong =>
      'Find eligible homeservers from the [matrix] universe. This will connect to joinmatrix.org.';

  @override
  String get connect => 'Connect';

  @override
  String get homeserverNotValid => 'This is no valid homeserver input.';

  @override
  String get pleaseProvideHomeserver => 'Please provide a homeserver.';

  @override
  String errorConnectingToHomeserver(String homeserver) {
    return 'Error connecting to server $homeserver. Please check your selection.';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return 'Connecting to $homeserver ...';
  }

  @override
  String welcomeToHomeserver(String homeserver) {
    return 'Welcome to $homeserver !';
  }

  @override
  String get howWouldYouLikeToConnect => 'How would you like to connect ?';

  @override
  String get loginPassword => 'Login using password';

  @override
  String get username => 'username';

  @override
  String get email => 'email';

  @override
  String get password => 'password';

  @override
  String get pleaseProvideEmail => 'Please provide your email.';

  @override
  String get pleaseProvidePassword => 'Please enter your password.';

  @override
  String get pleaseProvideUsername => 'Please enter your username.';

  @override
  String get emailMinimals =>
      'Your email should at least contain the @ symbol, a local part and your domain.';

  @override
  String get mxidSyntax =>
      'Allowed characters : a-z, 0-9 as well as the symbols ., _, =, -, /, and +.';

  @override
  String clientDisplayName(String platform) {
    return '< polycule > on $platform';
  }

  @override
  String get platformWeb => 'web';

  @override
  String get loginError => 'Error during login, please check your credentials.';

  @override
  String loginErrorMessage(String message) {
    return 'Error during login : $message';
  }

  @override
  String hajUser(String? localpart) {
    return 'Haj $localpart !';
  }

  @override
  String get syncInProgress => 'Sync in progress';

  @override
  String get initialSync => 'Initial sync in progress';

  @override
  String get syncOffline => 'Sync interrupted';

  @override
  String get syncFunctional => 'Sync state healthy';

  @override
  String lastSyncReceived(DateTime timestamp, Object duration) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jms(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return 'Last sync : $timestampString ($duration ms)';
  }
}
