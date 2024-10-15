import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

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
  String editedToday(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jm(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return 'Edited: $timestampString';
  }

  @override
  String editedAt(String timestamp) {
    return 'Edited: $timestamp';
  }

  @override
  String get authenticationRequired => 'Authentication required';

  @override
  String authenticateForAccount(Object mxid) {
    return 'Please authenticate with your credentials for $mxid.';
  }

  @override
  String replyUserSentDate(Object username, Object formattedDate) {
    return '$username wrote $formattedDate :';
  }

  @override
  String get view => 'View';

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
      'There is an incoming verification request, do you want to handle the verification request ?';

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
      'You don\'t have a verification method available ?';

  @override
  String get resetAccountWarning =>
      'You will use all your past messages. This cannot be undone.';

  @override
  String get verifyWithPassphrase => 'Verify with passphrase';

  @override
  String get passphraseNoWhitespace =>
      'The passphrase cannot contain any whitespace characters !';

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
  String sendingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files files',
      one: 'One file',
      zero: 'Sending no files.',
    );
    return '$_temp0 sending ...';
  }

  @override
  String get noFilesSelected => 'No files selected.';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get thisMonth => 'This month';

  @override
  String get lastMonth => 'Last month';

  @override
  String get download => 'Download';

  @override
  String get share => 'Share';

  @override
  String get saveAs => 'Save as';

  @override
  String get settings => 'Settings';

  @override
  String get errorDownloadingAttachment =>
      'Error downloading the message attachment.';

  @override
  String get retry => 'Retry';

  @override
  String get searchPromptLabel => 'Command, user, room name or MXID';

  @override
  String get appearanceAccessibilitySettings => 'Appearance and accessibility';

  @override
  String get polyculeSettings => 'Configure your < polycule >';

  @override
  String get systemLanguage => 'Device language';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get dark => 'Dark terminal';

  @override
  String get light => 'Light rose';

  @override
  String get systemTheme => 'System theme';

  @override
  String get fontAccessibility => 'Font accessibility';

  @override
  String get inclusiveSans => 'Increased readability font';

  @override
  String get openDyslexic => 'Dyslexia-assisting font';

  @override
  String get serif => 'Serif font';

  @override
  String get defaultFont => 'Default font';

  @override
  String get color => 'Color settings';

  @override
  String get systemColor => 'System color';

  @override
  String get defaultColor => 'Theme default color';

  @override
  String get customColor => 'Custom color';

  @override
  String get highContrast => 'High contrast';

  @override
  String get aboutPolycule => 'About < polycule >';

  @override
  String contentNotice(String notice) {
    return 'CN : « $notice »';
  }

  @override
  String get contentNoticeFallback => 'Content notice';

  @override
  String get webUriHandlerTitle => '< polycule > [matrix] client';

  @override
  String jumpToMessage(String message) {
    return 'Jump to message $message';
  }

  @override
  String get selectAccount => 'Select account to continue';

  @override
  String sharingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files files',
      one: 'a file',
    );
    return 'Sending $_temp0.';
  }

  @override
  String get sharingText => 'Share text to room';

  @override
  String get sendFiles => 'Send files';

  @override
  String get checkingTotalSendSize => 'Checking total send size ...';

  @override
  String totalSendSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'Total send size : $size bytes',
      one: 'Total send size : 1 byte',
      zero: 'Total send size : 0 bytes',
    );
    return '$_temp0';
  }

  @override
  String fileSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'File size : $size bytes',
      one: 'File size : 1 byte',
      zero: 'File size : 0 bytes',
    );
    return '$_temp0';
  }

  @override
  String mimeType(String? mimeType) {
    return 'File type : $mimeType';
  }

  @override
  String matrixRoomShareSubject(String roomname) {
    return 'Join the room « $roomname » on [matrix]';
  }

  @override
  String fileDownloadedTo(String name) {
    return 'File saved as « $name ».';
  }

  @override
  String get openFile => 'Open';

  @override
  String get compressFiles => 'Compress files';

  @override
  String get compressFilesSubtitle => 'For supported file types only';

  @override
  String get cancelSending => 'Cancel sending';

  @override
  String get retrySending => 'Retry sending';

  @override
  String get accountSettings => 'Account settings';

  @override
  String get previewRoom => 'Preview as guest';

  @override
  String get joinMatrixCall => 'Join [matrix] call';

  @override
  String matrixCallTooltip(String roomId) {
    return 'Call ID : $roomId';
  }

  @override
  String get pushSettings => 'Push notifications';

  @override
  String get unifiedPushUnavailable =>
      'UnifiedPush is not available on your device.';

  @override
  String get selectPushDistributor => 'Select your UnifiedPush distributor';

  @override
  String get disablePushNotifications => 'Disable push notifications';

  @override
  String get pushInformationPolycule =>
      'Currently, < polycule > only supports push notifications on Android. Linux support is planned.';

  @override
  String get unifiedPushAbout =>
      'You need to install a distributor for push notifications to work.\nYou can find more information at : https://unifiedpush.org/users/intro/';

  @override
  String get unifiedPushLink => 'https://unifiedpush.org/users/intro/';

  @override
  String get setupUnifiedPush => 'Setup UnifiedPush';

  @override
  String get googleFirebase => 'Google Firebase Cloud Messaging';

  @override
  String get newNotification => 'New message in < polycyule >';

  @override
  String get pushChannelName => 'Incoming messages';

  @override
  String get directChats => 'Direct message rooms';

  @override
  String get groups => 'Group rooms';

  @override
  String get unifiedPush => 'UnifiedPush';

  @override
  String get reply => 'Reply';

  @override
  String get edit => 'Edit';

  @override
  String get redact => 'Redact';

  @override
  String get copyMessage => 'Copy message';

  @override
  String get confirmRedact => 'Redact event';

  @override
  String redactEventLong(String eventId) {
    return 'Do you permanently want to redact the event $eventId ?';
  }

  @override
  String get logoutCommandSyntax => 'Logout from this account.';

  @override
  String get roomnameCommandSyntax => 'Set the room name to [name].';

  @override
  String get roomdescriptionCommandSyntax =>
      'Set the room description to [description].';

  @override
  String get sendCommandSyntax => 'Send a text message. [m.text]';

  @override
  String get meCommandSyntax => 'Describe your mood. [m.emote]';

  @override
  String get dmCommandSyntax => 'Create a DM room. [mxid] [--no-encryption?]';

  @override
  String get createCommandSyntax => 'Create a room. [name?] [--no-encryption?]';

  @override
  String get plainCommandSyntax =>
      'Send a text message without markdown parsing. [m.text]';

  @override
  String get htmlCommandSyntax => 'Send a text message in raw HTML. [m.text]';

  @override
  String get reactCommandSyntax => 'Reply with a reaction. [reaction]';

  @override
  String get joinCommandSyntax => 'Join a room. [mxid]';

  @override
  String get leaveCommandSyntax => 'Leave the present room.';

  @override
  String get opCommandSyntax => 'Set a member power level. [mxid] [50?]';

  @override
  String get kickCommandSyntax => 'Kick member. [mxid]';

  @override
  String get banCommandSyntax => 'Ban member. [mxid]';

  @override
  String get unbanCommandSyntax => 'Unban member. [mxid]';

  @override
  String get inviteCommandSyntax => 'Invite member. [mxid]';

  @override
  String get myroomnickCommandSyntax =>
      'Set a custom nick in this room. [displayname]';

  @override
  String get myroomavatarCommandSyntax =>
      'Set a custom mxc avatar in this room. [mxc]';

  @override
  String get discardsessionCommandSyntax =>
      'Discard your outbound room session.';

  @override
  String get clearcacheCommandSyntax => 'Clear the account\'s local cache.';

  @override
  String get markasdmCommandSyntax =>
      'Mark the current room as a DM with a member. [mxid]';

  @override
  String get markasgroupCommandSyntax =>
      'Remove the current room from DM list.';

  @override
  String get hugCommandSyntax => 'Send virtual hugs.';

  @override
  String get googlyCommandSyntax => 'Send virtual googly eyes.';

  @override
  String get cuddleCommandSyntax => 'Send virtual cuddles.';

  @override
  String get sendrawCommandSyntax => 'Send a raw event. [content]';

  @override
  String get ignoreCommandSyntax => 'Ignore a user. [mxid]';

  @override
  String get unignoreCommandSyntax => 'Unignore a user. [mxid]';

  @override
  String get noErrorReported => 'No error reported.';

  @override
  String get commandInvalid => 'This is no valid < polycule > command.';

  @override
  String get commandHelp => 'Show help';

  @override
  String get availableCommands => 'Available commands';

  @override
  String get commandError => 'Exit code 1';

  @override
  String get noStickerPacks =>
      'Neither your account nor this room has any sticker pack available.';

  @override
  String get react => 'Send reaction';
}
