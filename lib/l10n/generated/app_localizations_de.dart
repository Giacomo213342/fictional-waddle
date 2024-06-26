import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => '< polycule >';

  @override
  String get about => 'Info';

  @override
  String author(String author) {
    return 'Author: $author';
  }

  @override
  String get appSlogan =>
      'A geeky and efficient [matrix] client for power users.';

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
    return 'Could not connect $homeserver. Please check your selection.';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return 'Connecting to $homeserver …';
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
      'Your email must least contain the @ symbol, a local part and your domain.';

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
  String get loginError => 'Could not log in ; please check your credentials.';

  @override
  String loginErrorMessage(String message) {
    return 'Could not log in : $message';
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

  @override
  String get authenticationRequired => 'Authentication required';

  @override
  String authenticateForAccount(Object mxid) {
    return 'Please authenticate with your credentials for $mxid.';
  }

  @override
  String get passphraseNotEmpty => 'The passphrase can\'t be empty';

  @override
  String get cancel => 'Cancel';

  @override
  String get noMatch => 'No match';

  @override
  String get keysMatch => 'Keys match';

  @override
  String get wipeAccount => 'Wipe account';

  @override
  String get wipeAccountWarning =>
      'If you lost your device, you can wipe and reset your account. All messages and chats will be lost.';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get connectPreviousDevice => 'Connect previous device';

  @override
  String get connectPreviousDeviceLong => 'Please verify existing device.';

  @override
  String get deviceNotAvailable => 'I don\'t have my device available.';

  @override
  String get compareSasNumbers => 'Compare security numbers';

  @override
  String get compareSasExplanation =>
      'Check if the numbers on your device are identical with the numbers on the other device requesting the verification.';

  @override
  String get incomingVerificationRequest => 'Incoming verification request';

  @override
  String get waitingForVerification => 'Waiting for verification';

  @override
  String get waitingForVerificationFallback =>
      'Please verify using your second device or enter your recovery phrase.';

  @override
  String incomingVerificationRequestUser(String? user) {
    return '$user wants to verify';
  }

  @override
  String get incomingVerificationRequestMyself =>
      'There is an incoming verification request to verify another device for your account.';

  @override
  String get incomingVerificationRequestLong =>
      'There is an incoming verification request, do you want to handle the verification request?';

  @override
  String get reject => 'Reject';

  @override
  String get proceed => 'Proceed';

  @override
  String get enterRecoveryPhrase => 'Enter recovery phrase';

  @override
  String get keyVerificationErrorGeneric =>
      'There was an error verifying your device.';

  @override
  String get keyVerificationErrorUser => 'The verification was rejected.';

  @override
  String get close => 'Close';

  @override
  String get verificationSuccessful => 'Key verification successful';

  @override
  String get verifyLogin => 'Verify your new login';

  @override
  String get finish => 'Finish';

  @override
  String get or => 'or';

  @override
  String get verifyWithOtherDevice => 'Verify with other device';

  @override
  String get verifyMethodsNotAvailable =>
      'You don\'t have a verification method available?';

  @override
  String get verifyWithPassphrase => 'Verify with passphrase';

  @override
  String get passphraseNoWhitespace =>
      'The passphrase cannot contain any whitespace characters!';

  @override
  String get errorTryAgain => 'An error occurred. Please try again.';

  @override
  String get submit => 'submit';

  @override
  String get togglePassword => 'Toggle password visibility';

  @override
  String get loggingInToClient => 'Login to account';

  @override
  String get pendingInvite => 'Pending invite';

  @override
  String get invite => 'Invite';

  @override
  String inviteLongRoom(String roomname) {
    return 'You are invited to join the room : « $roomname ».';
  }

  @override
  String inviteLongDM(Object displayname) {
    return 'You are invited to discuss with « $displayname ».';
  }

  @override
  String roomParticipants(int participants) {
    String _temp0 = intl.Intl.pluralLogic(
      participants,
      locale: localeName,
      other: '$participants participants',
      one: '1 participant',
      zero: 'No participants',
    );
    return '$_temp0';
  }

  @override
  String get joinRoom => 'Join room';

  @override
  String get knockRoom => 'Knock to join';

  @override
  String get youCannotJoinThisRoom => 'You cannot join this room.';

  @override
  String get addAccount => 'Add another account';

  @override
  String get regionAccountSwitcher => 'Screen region: Account switcher.';

  @override
  String get regionChatContents => 'Screen region: Chat content.';

  @override
  String get loadingHomeservers =>
      'Loading homeservers. Progress unknown. Please wait.';

  @override
  String get send => 'Send';

  @override
  String get typeGroupImages => 'Images';

  @override
  String get typeGroupVideos => 'Videos';

  @override
  String get typeGroupAudio => 'Audio';

  @override
  String get typeGroupFiles => 'All files';

  @override
  String get msgTypeText => 'Send a regular text message.';

  @override
  String get msgTypeEmote => 'Describe your mood.';

  @override
  String get msgTypeNotice =>
      'Send an informative message bots cannot reply to.';

  @override
  String get msgTypeImage => 'Send an image file.';

  @override
  String get msgTypeVideo => 'Send a video file.';

  @override
  String get msgTypeAudio => 'Send an audio file.';

  @override
  String get msgTypeFile => 'Send a file.';

  @override
  String get msgTypeLocation => 'Share your location.';

  @override
  String get msgTypeSticker => 'Send a sticker.';

  @override
  String get msgTypeBadEncrypted =>
      'Annoy your peer with a message they cannot decrypt.';

  @override
  String get msgTypeNone => 'Send no message.';

  @override
  String filesSelected(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files files',
      one: 'One file',
      zero: 'No files',
    );
    return '$_temp0 selected. Sending files is not supported yet.';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';
}
