// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

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
  String get loginLegacySso => 'Login using legacy SSO';

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
  String clientDisplayNameHostname(String hostname, String platform) {
    return '< polycule > on $hostname ($platform)';
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
  String lastSyncReceived(DateTime timestamp, int duration) {
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
  String authenticateForAccount(String mxid) {
    return 'Please authenticate with your credentials for $mxid.';
  }

  @override
  String replyUserSentDate(String username, String formattedDate) {
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
  String get compareSasNumbers => 'Compare SAS security numbers';

  @override
  String get compareSasEmojis => 'Compare SAS security emojis';

  @override
  String get compareSasExplanation =>
      'Check if the SAS on your device are identical with the SAS on the other device requesting the verification.';

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
  String get keyVerificationErrorUser => 'The verification was canceled.';

  @override
  String get close => 'Close';

  @override
  String get verificationSuccessful => 'Key verification successful';

  @override
  String get verifyLogin => 'Verify your key material';

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
  String matrixUserShareSubject(String mxid) {
    return 'Contact « $mxid » on [matrix]';
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

  @override
  String get logs => 'Application logs';

  @override
  String get reload => 'Reload';

  @override
  String get runtimeError => 'Your < polycule > was buggy';

  @override
  String get logSingleError => 'Anonymously share';

  @override
  String get enableSentry => 'Always share';

  @override
  String get errorReporting => 'Error reporting';

  @override
  String get errorReportingLong =>
      'You can enable error reporting to help finding bugs in < polycule >.';

  @override
  String get errorReportingPrivacy =>
      'This will connect to GitLab.com, the source code host of < polycyle > and anonymously share occurring errors and their causes. This will not share any personal data to the developer.';

  @override
  String get learnMore => 'Learn more';

  @override
  String get gitLabPrivacy =>
      'https://gitlab.com/help/operations/error_tracking.md';

  @override
  String get fontSize => 'Font size';

  @override
  String get reset => 'Reset';

  @override
  String fontScaleLabel(double scale) {
    final intl.NumberFormat scaleNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String scaleString = scaleNumberFormat.format(scale);

    return '$scaleString';
  }

  @override
  String get openDirectChat => 'Open direct chat';

  @override
  String get startDirectChat => 'Start direct chat';

  @override
  String get ignoreUser => 'Ignore';

  @override
  String get unignoreUser => 'Unignore';

  @override
  String get ignoreToggleWaiting =>
      'Processing ignore state. This will take a while.';

  @override
  String get roomStateWtf => 'This room\'s security is a mess. Better avoid.';

  @override
  String get roomStatePublic => 'This room is publicly visible for everyone';

  @override
  String get roomStatePublicKnock =>
      'This room is publicly visible for everyone but they must knock before joining.';

  @override
  String get roomStateOpen =>
      'This room is open for everyone who knows its link.';

  @override
  String get roomStateKnock => 'Users must knock before joining this room.';

  @override
  String get roomStateSpace => 'This room is open for space members only.';

  @override
  String get roomStateUnpublic => 'This room is private but not encrypted.';

  @override
  String get roomStateEncrypted =>
      'This room is encrypted but some members are not verified.';

  @override
  String get roomStateVerifiedEncrypted =>
      'This room is encrypted and every session is cross-signed.';

  @override
  String get oidcAppName => '< polycule >';

  @override
  String get oidcContact => 'info@braid.business';

  @override
  String get oidcAppUrl => 'https://polycule.im/web';

  @override
  String get oidcLogoUrl =>
      'https://polycule.im/web/assets/assets/logo/logo-circle.png';

  @override
  String get oidcTosUrl => 'https://polycule.im/web/tos.html';

  @override
  String get oicPolicyUri => 'https://polycule.im/web/policy.html';

  @override
  String get loginOidc => 'Login using OpenID Connect';

  @override
  String get oidcConfirm => 'Confirm';

  @override
  String get manageSessions => 'Manage sessions';

  @override
  String get deactivateAccount => 'Deactivate account';

  @override
  String get networkSettings => 'Network settings';

  @override
  String get useSystemProxy => 'Permit device proxy settings';

  @override
  String get verifyCertificates => 'Verify TLS certificates';

  @override
  String get verifyTlsCertificatesAndroid =>
      'For older Android versions, the rotated Let\'s Encrypt ISRG ROOT X1 certificate is already included.';

  @override
  String get sendTlsSNI => 'Send plain text Server Name Indication';

  @override
  String get minTlsVersion => 'Minimum required TLS version by the homeserver';

  @override
  String get tls12 => 'TLS 1.2';

  @override
  String get tls13 => 'TLS 1.3';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String get markRead => 'Mark as read';

  @override
  String get markUnread => 'Mark as unread';

  @override
  String get leaveRoom => 'Leave room';

  @override
  String leaveRoomLong(String name) {
    return 'Please confirm to permanently leave the room « $name ».';
  }

  @override
  String get userDetails => 'View user profile';

  @override
  String get markMute => 'Mute room';

  @override
  String get markUnmute => 'Unmute room';

  @override
  String get copyRoomAddress => 'Copy public room address';

  @override
  String get search => 'Search';

  @override
  String get startVerification => 'Start verification';

  @override
  String get keyVerificationRequestSent => 'Key verification request sent.';

  @override
  String get noHomeserverConnection => 'No connection to homeserver.';

  @override
  String get emojiSettings => 'Emoji settings';

  @override
  String get defaultEmojiTone => 'Default emoji tone';

  @override
  String get autoplayAnimations =>
      'Automatically play animated images and stickers';

  @override
  String get yellowSkin => 'Yellow skin';

  @override
  String get paleSkin => 'Pale skin';

  @override
  String get demiPaleSkin => 'Demi pale skin';

  @override
  String get mediumSkin => 'Medium skin';

  @override
  String get brownSkin => 'Brown skin';

  @override
  String get blackSkin => 'Black skin';

  @override
  String get roomDetails => 'Room details';

  @override
  String get errorSendingSticker => 'Error sending custom sticker.';

  @override
  String get viewSourceCode => 'View source code';

  @override
  String get eventSourceCode => 'Event source code';

  @override
  String get eventSourceContent => 'Event content';

  @override
  String get eventSourceJson => 'Full JSON';

  @override
  String get eventSourceOriginal => 'Original event';

  @override
  String get eventSourceBodyRaw => 'Event body (raw)';

  @override
  String get eventSourceBodyHtml => 'Event body (HTML)';

  @override
  String get eventSourceUnsigned => 'Unsigned content';

  @override
  String get eventRendered => 'Rendered event';

  @override
  String get eventQuoted => 'Quoted event';

  @override
  String get eventPreview => 'Event preview';

  @override
  String get blurHash => 'Blur hash';

  @override
  String get linuxOidcWorkaround =>
      'In case your web browser won\'t prompt you to open < polycule > after logging in, please ensure you granted to handle OAuth2.0 redirects in < polycule > by launching the following command in a terminal emulator :';

  @override
  String get linuxOidcWorkaroundSnippet =>
      'gio mime x-scheme-handler/im.polycule business.braid.polycule.desktop';

  @override
  String get setupSSSSLoading =>
      'Encryption setup running. This might take a while.';

  @override
  String get sessionId => 'Session ID';

  @override
  String get sessionIpAddress => 'Last IP address';

  @override
  String get sessionLastSeen => 'Last seen';

  @override
  String get delete => 'Delete';

  @override
  String get verify => 'Verify';

  @override
  String get verifyAgain => 'Verify again';

  @override
  String get rename => 'Rename';

  @override
  String get renameDevice => 'Rename device';

  @override
  String get deviceName => 'Device display name';

  @override
  String get renameDeviceHint => 'Leave blank to remove display name';

  @override
  String get openInIDP => 'Open in identity provider';

  @override
  String get deviceNoEncryption => 'Does not support encryption';

  @override
  String get deviceVerified => 'Keys verified';

  @override
  String get deviceUnverified => 'Keys unverified';

  @override
  String get deviceBlocked => 'Device blocked';

  @override
  String get logout => 'Logout';

  @override
  String get logoutWarning => 'Confirm logout';

  @override
  String get logoutWarningLong =>
      'When you log out and neither have any other session nor your recovery phrase, you will lose access to all you [matrix] messages.';

  @override
  String get keyBackupAvailable => 'SSSS backup';

  @override
  String get keyBackupExplanation =>
      'Use Secure Secret Storage and Sharing to securely backup message keys for all your devices.';

  @override
  String get ssssRecoveryKey => 'SSSS recovery key';

  @override
  String get ssssRecoveryKeyExplanation =>
      'Carefully store your Secure Secret Storage and Sharing recovery key at a secure place. Without your recovery key, all past messages will be lost forever.';

  @override
  String get confirmSSSSKeyStored => 'Key stored';

  @override
  String get yourCurrentDevice => 'Your current device';

  @override
  String get moveClientTooltip => 'Move here';

  @override
  String get displayName => 'Display name';

  @override
  String get yourDisplayName => 'Your display name';

  @override
  String get displayNameHint => 'This is shown on your public profile.';

  @override
  String get changeDisplayName => 'Change display name';

  @override
  String get scanQrCode => 'Scan QR code';

  @override
  String get compareSas => 'Compare SAS secret';

  @override
  String get confirmQrScanned => 'QR code successfully scanned.';

  @override
  String get confirm => 'Confirm';

  @override
  String get scanQrWithOtherDevice =>
      'Scan this QR code with your other device.';

  @override
  String get clientSwitcher => 'Switch account';

  @override
  String get block => 'Block';

  @override
  String get unblock => 'Unblock';

  @override
  String get sessions => 'Sessions';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appName => '< polycule >';

  @override
  String get about => '关于';

  @override
  String author(String author) {
    return '作者：$author';
  }

  @override
  String get appSlogan => '为高阶用户打造的极客高效 [matrix] 客户端。';

  @override
  String get repoLabel => '源代码（GitLab）';

  @override
  String get releaseNotes => '更新日志';

  @override
  String get buyMeACoffee => '请我喝杯咖啡';

  @override
  String get homeserverHeadline => 'Haj！欢迎来到 < polycule >';

  @override
  String get aMatrixClient => '- 又一个 [matrix] 客户端';

  @override
  String get connectToHomeserver => '连接到您的主服务器';

  @override
  String get discoverHomeservers => '发现新主服务器';

  @override
  String get newToMatrixLong =>
      '在 [matrix] 宇宙中查找可用主服务器。此操作将连接到 joinmatrix.org。';

  @override
  String get connect => '连接';

  @override
  String get homeserverNotValid => '这不是有效的主服务器输入。';

  @override
  String get pleaseProvideHomeserver => '请提供主服务器。';

  @override
  String errorConnectingToHomeserver(String homeserver) {
    return '无法连接 $homeserver。请检查您的选择。';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return '正在连接 $homeserver …';
  }

  @override
  String welcomeToHomeserver(String homeserver) {
    return '欢迎来到 $homeserver！';
  }

  @override
  String get howWouldYouLikeToConnect => '您想如何连接？';

  @override
  String get loginPassword => '使用密码登录';

  @override
  String get loginLegacySso => '使用传统 SSO 登录';

  @override
  String get username => '用户名';

  @override
  String get email => '邮箱';

  @override
  String get password => '密码';

  @override
  String get pleaseProvideEmail => '请提供您的邮箱。';

  @override
  String get pleaseProvidePassword => '请输入您的密码。';

  @override
  String get pleaseProvideUsername => '请输入您的用户名。';

  @override
  String get emailMinimals => '您的邮箱必须至少包含 @ 符号、本地部分和域名。';

  @override
  String get mxidSyntax => '允许的字符：a-z、0-9 以及符号 ., _, =, -, / 和 +。';

  @override
  String clientDisplayName(String platform) {
    return '< polycule > 于 $platform';
  }

  @override
  String clientDisplayNameHostname(String hostname, String platform) {
    return '< polycule > 于 $hostname（$platform）';
  }

  @override
  String get platformWeb => '网页';

  @override
  String get loginError => '无法登录；请检查您的凭据。';

  @override
  String loginErrorMessage(String message) {
    return '无法登录：$message';
  }

  @override
  String hajUser(String? localpart) {
    return 'Haj $localpart！';
  }

  @override
  String get syncInProgress => '同步进行中';

  @override
  String get initialSync => '初始同步进行中';

  @override
  String get syncOffline => '同步中断';

  @override
  String get syncFunctional => '同步状态正常';

  @override
  String lastSyncReceived(DateTime timestamp, int duration) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jms(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return '上次同步：$timestampString（$duration 毫秒）';
  }

  @override
  String editedToday(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jm(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return '编辑时间：$timestampString';
  }

  @override
  String editedAt(String timestamp) {
    return '编辑时间：$timestamp';
  }

  @override
  String get authenticationRequired => '需要身份验证';

  @override
  String authenticateForAccount(String mxid) {
    return '请使用您的凭据验证 $mxid。';
  }

  @override
  String replyUserSentDate(String username, String formattedDate) {
    return '$username 写于 $formattedDate：';
  }

  @override
  String get view => '查看';

  @override
  String get passphraseNotEmpty => '密码短语不能为空';

  @override
  String get cancel => '取消';

  @override
  String get noMatch => '无匹配项';

  @override
  String get keysMatch => '密钥匹配';

  @override
  String get wipeAccount => '清除账号';

  @override
  String get wipeAccountWarning => '如果您丢失了设备，可以清除并重置账号。所有消息和聊天将会丢失。';

  @override
  String get deleteAll => '全部删除';

  @override
  String get previous => '上一个';

  @override
  String get next => '下一个';

  @override
  String get connectPreviousDevice => '连接之前的设备';

  @override
  String get connectPreviousDeviceLong => '请验证现有设备。';

  @override
  String get deviceNotAvailable => '我无法使用我的设备。';

  @override
  String get compareSasNumbers => '比较 SAS 安全数字';

  @override
  String get compareSasEmojis => '比较 SAS 安全表情符号';

  @override
  String get compareSasExplanation => '请检查您设备上的 SAS 是否与请求验证的另一台设备上的 SAS 完全一致。';

  @override
  String get incomingVerificationRequest => '收到验证请求';

  @override
  String get waitingForVerification => '等待验证';

  @override
  String get waitingForVerificationFallback => '请使用您的第二台设备验证或输入恢复短语。';

  @override
  String incomingVerificationRequestUser(String? user) {
    return '$user 想要进行验证';
  }

  @override
  String get incomingVerificationRequestMyself => '收到验证请求，需要为您的账号验证另一台设备。';

  @override
  String get incomingVerificationRequestLong => '收到验证请求，您想处理该验证请求吗？';

  @override
  String get reject => '拒绝';

  @override
  String get proceed => '继续';

  @override
  String get enterRecoveryPhrase => '输入恢复短语';

  @override
  String get keyVerificationErrorGeneric => '验证您的设备时发生错误。';

  @override
  String get keyVerificationErrorUser => '验证已取消。';

  @override
  String get close => '关闭';

  @override
  String get verificationSuccessful => '密钥验证成功';

  @override
  String get verifyLogin => '验证您的密钥材料';

  @override
  String get finish => '完成';

  @override
  String get or => '或';

  @override
  String get verifyWithOtherDevice => '使用其它设备进行验证';

  @override
  String get verifyMethodsNotAvailable => '您没有可用的验证方法？';

  @override
  String get resetAccountWarning => '您将失去所有过去的消息。这无法撤销。';

  @override
  String get verifyWithPassphrase => '使用短语进行验证';

  @override
  String get passphraseNoWhitespace => '短语不能包含任何空格字符！';

  @override
  String get errorTryAgain => '发生错误。请重试。';

  @override
  String get submit => '提交';

  @override
  String get togglePassword => '切换密码可见性';

  @override
  String get loggingInToClient => '登录账号';

  @override
  String get pendingInvite => '待处理邀请';

  @override
  String get invite => '邀请';

  @override
  String inviteLongRoom(String roomname) {
    return '您被邀请加入房间：「$roomname」。';
  }

  @override
  String inviteLongDM(Object displayname) {
    return '您被邀请与「$displayname」进行交流。';
  }

  @override
  String roomParticipants(int participants) {
    String _temp0 = intl.Intl.pluralLogic(
      participants,
      locale: localeName,
      other: '$participants 名参与者',
      one: '1 名参与者',
      zero: '没有参与者',
    );
    return '$_temp0';
  }

  @override
  String get joinRoom => '加入房间';

  @override
  String get knockRoom => '请求加入';

  @override
  String get youCannotJoinThisRoom => '您无法加入此房间。';

  @override
  String get addAccount => '添加另一个账号';

  @override
  String get regionAccountSwitcher => '屏幕区域：账号切换器。';

  @override
  String get regionChatContents => '屏幕区域：聊天内容。';

  @override
  String get loadingHomeservers => '正在加载服务器。进度未知。请等待。';

  @override
  String get send => '发送';

  @override
  String get typeGroupImages => '图片';

  @override
  String get typeGroupVideos => '视频';

  @override
  String get typeGroupAudio => '音频';

  @override
  String get typeGroupFiles => '所有文件';

  @override
  String get msgTypeText => '发送普通文本消息。';

  @override
  String get msgTypeEmote => '描述您的心情。';

  @override
  String get msgTypeNotice => '发送机器人无法回复的信息。';

  @override
  String get msgTypeImage => '发送图片文件。';

  @override
  String get msgTypeVideo => '发送视频文件。';

  @override
  String get msgTypeAudio => '发送音频文件。';

  @override
  String get msgTypeFile => '发送文件。';

  @override
  String get msgTypeLocation => '分享您的位置。';

  @override
  String get msgTypeSticker => '发送贴纸。';

  @override
  String get msgTypeBadEncrypted => '向您的同行发送无法解密的消息。';

  @override
  String get msgTypeNone => '未发送消息。';

  @override
  String sendingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files 个文件',
      one: '1 个文件',
      zero: '未发送文件。',
    );
    return '$_temp0 正在发送...';
  }

  @override
  String get noFilesSelected => '未选择文件。';

  @override
  String get yesterday => '昨天';

  @override
  String get thisMonth => '本月';

  @override
  String get lastMonth => '上月';

  @override
  String get download => '下载';

  @override
  String get share => '分享';

  @override
  String get saveAs => '另存为';

  @override
  String get settings => '设置';

  @override
  String get errorDownloadingAttachment => '下载消息附件时发生错误。';

  @override
  String get retry => '重试';

  @override
  String get searchPromptLabel => '命令、用户、房间名称或 MXID';

  @override
  String get appearanceAccessibilitySettings => '外观和辅助功能';

  @override
  String get polyculeSettings => '配置您的 < polycule >';

  @override
  String get systemLanguage => '设备语言';

  @override
  String get language => '语言';

  @override
  String get theme => '主题';

  @override
  String get dark => '深色终端';

  @override
  String get light => '浅色玫瑰';

  @override
  String get systemTheme => '系统主题';

  @override
  String get fontAccessibility => '字体辅助功能';

  @override
  String get inclusiveSans => '提高可读性的字体';

  @override
  String get openDyslexic => '帮助阅读障碍的字体';

  @override
  String get serif => '衬线字体';

  @override
  String get defaultFont => '默认字体';

  @override
  String get color => '颜色设置';

  @override
  String get systemColor => '系统颜色';

  @override
  String get defaultColor => '主题默认颜色';

  @override
  String get customColor => '自定义颜色';

  @override
  String get highContrast => '高对比度';

  @override
  String get aboutPolycule => '关于 < polycule >';

  @override
  String contentNotice(String notice) {
    return '内容警告：「$notice」';
  }

  @override
  String get contentNoticeFallback => '内容警告';

  @override
  String get webUriHandlerTitle => '< polycule > [matrix] 客户端';

  @override
  String jumpToMessage(String message) {
    return '跳转到消息 $message';
  }

  @override
  String get selectAccount => '选择账号继续';

  @override
  String sharingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files 个文件',
      one: '一个文件',
    );
    return '正在发送 $_temp0。';
  }

  @override
  String get sharingText => '分享文本到房间';

  @override
  String get sendFiles => '发送文件';

  @override
  String get checkingTotalSendSize => '正在检查总发送大小...';

  @override
  String totalSendSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: '总发送大小：$size 字节',
      one: '总发送大小：1 字节',
      zero: '总发送大小：0 字节',
    );
    return '$_temp0';
  }

  @override
  String fileSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: '文件大小：$size 字节',
      one: '文件大小：1 字节',
      zero: '文件大小：0 字节',
    );
    return '$_temp0';
  }

  @override
  String mimeType(String? mimeType) {
    return '文件类型：$mimeType';
  }

  @override
  String matrixRoomShareSubject(String roomname) {
    return '在 [matrix] 加入房间 « $roomname »';
  }

  @override
  String matrixUserShareSubject(String mxid) {
    return '在 [matrix] 联系 « $mxid »';
  }

  @override
  String fileDownloadedTo(String name) {
    return '文件已保存为 « $name »。';
  }

  @override
  String get openFile => '打开';

  @override
  String get compressFiles => '压缩文件';

  @override
  String get compressFilesSubtitle => '仅支持的文件类型';

  @override
  String get cancelSending => '取消发送';

  @override
  String get retrySending => '重试发送';

  @override
  String get accountSettings => '账号设置';

  @override
  String get previewRoom => '以访客身份预览';

  @override
  String get joinMatrixCall => '加入 [matrix] 通话';

  @override
  String matrixCallTooltip(String roomId) {
    return '通话 ID：$roomId';
  }

  @override
  String get pushSettings => '推送通知';

  @override
  String get unifiedPushUnavailable => '您的设备上无法使用 UnifiedPush。';

  @override
  String get selectPushDistributor => '选择您的 UnifiedPush 分发器';

  @override
  String get disablePushNotifications => '禁用推送通知';

  @override
  String get pushInformationPolycule =>
      '目前，< polycule > 仅支持 Android 上的推送通知。Linux 支持正在计划中。';

  @override
  String get unifiedPushAbout =>
      '您需要安装分发器才能使推送通知正常工作。\n您可以在此了解更多信息：https://unifiedpush.org/users/intro/';

  @override
  String get unifiedPushLink => 'https://unifiedpush.org/users/intro/';

  @override
  String get setupUnifiedPush => '设置 UnifiedPush';

  @override
  String get googleFirebase => 'Google Firebase 云消息';

  @override
  String get newNotification => '在 < polycyule > 中有新消息';

  @override
  String get pushChannelName => '收到的消息';

  @override
  String get directChats => '私聊房间';

  @override
  String get groups => '群组房间';

  @override
  String get unifiedPush => 'UnifiedPush';

  @override
  String get reply => '回复';

  @override
  String get edit => '编辑';

  @override
  String get redact => '撤回';

  @override
  String get copyMessage => '复制消息';

  @override
  String get confirmRedact => '撤回事件';

  @override
  String redactEventLong(String eventId) {
    return '您确定要永久撤回事件 $eventId 吗？';
  }

  @override
  String get logoutCommandSyntax => '退出此账号。';

  @override
  String get roomnameCommandSyntax => '将房间名称设置为 [name]。';

  @override
  String get roomdescriptionCommandSyntax => '将房间描述设置为 [description]。';

  @override
  String get sendCommandSyntax => '发送文本消息。[m.text]';

  @override
  String get meCommandSyntax => '描述您的心情。[m.emote]';

  @override
  String get dmCommandSyntax => '创建一个私聊房间。[mxid] [--no-encryption?]';

  @override
  String get createCommandSyntax => '创建一个房间。[name?] [--no-encryption?]';

  @override
  String get plainCommandSyntax => '发送不带 markdown 解析的文本消息。[m.text]';

  @override
  String get htmlCommandSyntax => '以原始 HTML 格式发送文本消息。[m.text]';

  @override
  String get reactCommandSyntax => '用表情回复。[reaction]';

  @override
  String get joinCommandSyntax => '加入房间。[mxid]';

  @override
  String get leaveCommandSyntax => '离开当前房间。';

  @override
  String get opCommandSyntax => '设置成员权限等级。[mxid] [50?]';

  @override
  String get kickCommandSyntax => '踢出成员。[mxid]';

  @override
  String get banCommandSyntax => '封禁成员。[mxid]';

  @override
  String get unbanCommandSyntax => '解除封禁成员。[mxid]';

  @override
  String get inviteCommandSyntax => '邀请成员。[mxid]';

  @override
  String get myroomnickCommandSyntax => '在此房间设置自定义昵称。[displayname]';

  @override
  String get myroomavatarCommandSyntax => '在此房间设置自定义 mxc 头像。[mxc]';

  @override
  String get discardsessionCommandSyntax => '丢弃您的房间会话。';

  @override
  String get clearcacheCommandSyntax => '清除账号本地缓存。';

  @override
  String get markasdmCommandSyntax => '将当前房间标记为与某成员的私聊。[mxid]';

  @override
  String get markasgroupCommandSyntax => '将当前房间从私聊列表中移除。';

  @override
  String get hugCommandSyntax => '发送虚拟拥抱。';

  @override
  String get googlyCommandSyntax => '发送虚拟滑稽眼睛。';

  @override
  String get cuddleCommandSyntax => '发送虚拟依偎。';

  @override
  String get sendrawCommandSyntax => '发送原始事件。[content]';

  @override
  String get ignoreCommandSyntax => '忽略用户。[mxid]';

  @override
  String get unignoreCommandSyntax => '取消忽略用户。[mxid]';

  @override
  String get noErrorReported => '未报告任何错误。';

  @override
  String get commandInvalid => '这不是有效的 < polycule > 命令。';

  @override
  String get commandHelp => '显示帮助';

  @override
  String get availableCommands => '可用命令';

  @override
  String get commandError => '退出码 1';

  @override
  String get noStickerPacks => '您的账号和此房间都没有可用的贴纸包。';

  @override
  String get react => '发送表情';

  @override
  String get logs => '应用日志';

  @override
  String get reload => '重新加载';

  @override
  String get runtimeError => '您的 < polycule > 出现了问题';

  @override
  String get logSingleError => '匿名分享';

  @override
  String get enableSentry => '始终分享';

  @override
  String get errorReporting => '错误报告';

  @override
  String get errorReportingLong => '您可以启用错误报告，帮助在 < polycule > 中查找漏洞。';

  @override
  String get errorReportingPrivacy =>
      '这将连接到 < polycyle > 的源代码托管平台 GitLab.com，并匿名分享发生的错误及其原因。不会向开发者分享任何个人数据。';

  @override
  String get learnMore => '了解更多';

  @override
  String get gitLabPrivacy =>
      'https://gitlab.com/help/operations/error_tracking.md';

  @override
  String get fontSize => '字体大小';

  @override
  String get reset => '重置';

  @override
  String fontScaleLabel(double scale) {
    final intl.NumberFormat scaleNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String scaleString = scaleNumberFormat.format(scale);

    return '$scaleString';
  }

  @override
  String get openDirectChat => '打开私聊';

  @override
  String get startDirectChat => '开始私聊';

  @override
  String get ignoreUser => '忽略';

  @override
  String get unignoreUser => '取消忽略';

  @override
  String get ignoreToggleWaiting => '正在处理忽略状态。这将需要一些时间。';

  @override
  String get roomStateWtf => '此房间的安全性很混乱。最好避免进入。';

  @override
  String get roomStatePublic => '此房间对所有人公开可见';

  @override
  String get roomStatePublicKnock => '此房间对所有人公开可见，但加入前必须敲门。';

  @override
  String get roomStateOpen => '知道链接的任何人都可以加入此房间。';

  @override
  String get roomStateKnock => '用户必须敲门后才能加入此房间。';

  @override
  String get roomStateSpace => '此房间仅对空间成员开放。';

  @override
  String get roomStateUnpublic => '此房间为私有，但未加密。';

  @override
  String get roomStateEncrypted => '此房间已加密，但部分成员未验证。';

  @override
  String get roomStateVerifiedEncrypted => '此房间已加密，且每个会话都已交叉签名。';

  @override
  String get oidcAppName => '< polycule >';

  @override
  String get oidcContact => 'info@braid.business';

  @override
  String get oidcAppUrl => 'https://polycule.im/web';

  @override
  String get oidcLogoUrl =>
      'https://polycule.im/web/assets/assets/logo/logo-circle.png';

  @override
  String get oidcTosUrl => 'https://polycule.im/web/tos.html';

  @override
  String get oicPolicyUri => 'https://polycule.im/web/policy.html';

  @override
  String get loginOidc => '使用 OpenID Connect 登录';

  @override
  String get oidcConfirm => '确认';

  @override
  String get manageSessions => '管理会话';

  @override
  String get deactivateAccount => '停用账号';

  @override
  String get networkSettings => '网络设置';

  @override
  String get useSystemProxy => '允许设备代理设置';

  @override
  String get verifyCertificates => '验证 TLS 证书';

  @override
  String get verifyTlsCertificatesAndroid =>
      '对于较旧的 Android 版本，已包含轮换后的 Let\'s Encrypt ISRG ROOT X1 证书。';

  @override
  String get sendTlsSNI => '发送明文服务器名称指示';

  @override
  String get minTlsVersion => '主服务器所需的最低 TLS 版本';

  @override
  String get tls12 => 'TLS 1.2';

  @override
  String get tls13 => 'TLS 1.3';

  @override
  String get favoriteAdd => '添加到收藏';

  @override
  String get favoriteRemove => '从收藏中移除';

  @override
  String get markRead => '标记为已读';

  @override
  String get markUnread => '标记为未读';

  @override
  String get leaveRoom => '离开房间';

  @override
  String leaveRoomLong(String name) {
    return '请确认永久离开房间「$name」。';
  }

  @override
  String get userDetails => '查看用户资料';

  @override
  String get markMute => '静音房间';

  @override
  String get markUnmute => '取消静音房间';

  @override
  String get copyRoomAddress => '复制公共房间地址';

  @override
  String get search => '搜索';

  @override
  String get startVerification => '开始验证';

  @override
  String get keyVerificationRequestSent => '密钥验证请求已发送。';

  @override
  String get noHomeserverConnection => '无法连接到主服务器。';

  @override
  String get emojiSettings => '表情设置';

  @override
  String get defaultEmojiTone => '默认表情色调';

  @override
  String get autoplayAnimations => '自动播放动图和贴纸';

  @override
  String get yellowSkin => '黄色皮肤';

  @override
  String get paleSkin => '浅色皮肤';

  @override
  String get demiPaleSkin => '半浅色皮肤';

  @override
  String get mediumSkin => '中等皮肤';

  @override
  String get brownSkin => '棕色皮肤';

  @override
  String get blackSkin => '黑色皮肤';

  @override
  String get roomDetails => '房间详情';

  @override
  String get errorSendingSticker => '发送自定义贴纸时出错。';

  @override
  String get viewSourceCode => '查看源代码';

  @override
  String get eventSourceCode => '事件源代码';

  @override
  String get eventSourceContent => '事件内容';

  @override
  String get eventSourceJson => '完整 JSON';

  @override
  String get eventSourceOriginal => '原始事件';

  @override
  String get eventSourceBodyRaw => '事件内容（原始）';

  @override
  String get eventSourceBodyHtml => '事件内容（HTML）';

  @override
  String get eventSourceUnsigned => '未签名内容';

  @override
  String get eventRendered => '已渲染事件';

  @override
  String get eventQuoted => '引用的事件';

  @override
  String get eventPreview => '事件预览';

  @override
  String get blurHash => '模糊哈希';

  @override
  String get linuxOidcWorkaround =>
      '如果您的网页浏览器在登录后没有提示您打开 < polycule >，请确保您已授权 < polycule > 处理 OAuth2.0 重定向，可在终端模拟器中运行以下命令：';

  @override
  String get linuxOidcWorkaroundSnippet =>
      'gio mime x-scheme-handler/im.polycule business.braid.polycule.desktop';

  @override
  String get setupSSSSLoading => '正在进行加密设置。这可能需要一些时间。';

  @override
  String get sessionId => '会话 ID';

  @override
  String get sessionIpAddress => '上次 IP 地址';

  @override
  String get sessionLastSeen => '上次活跃';

  @override
  String get delete => '删除';

  @override
  String get verify => '验证';

  @override
  String get verifyAgain => '再次验证';

  @override
  String get rename => '重命名';

  @override
  String get renameDevice => '重命名设备';

  @override
  String get deviceName => '设备显示名称';

  @override
  String get renameDeviceHint => '留空以移除显示名称';

  @override
  String get openInIDP => '在身份提供方中打开';

  @override
  String get deviceNoEncryption => '不支持加密';

  @override
  String get deviceVerified => '密钥已验证';

  @override
  String get deviceUnverified => '密钥未验证';

  @override
  String get deviceBlocked => '设备已屏蔽';

  @override
  String get logout => '退出登录';

  @override
  String get logoutWarning => '确认退出登录';

  @override
  String get logoutWarningLong => '当您退出登录且没有其它会话或恢复短语时，您将无法访问所有 [matrix] 消息。';

  @override
  String get keyBackupAvailable => 'SSSS 备份';

  @override
  String get keyBackupExplanation => '使用安全密钥存储与共享功能，为您所有设备安全备份消息密钥。';

  @override
  String get ssssRecoveryKey => 'SSSS 恢复密钥';

  @override
  String get ssssRecoveryKeyExplanation =>
      '请将您的安全密钥存储与共享恢复密钥妥善保管在安全的地方。没有恢复密钥，所有历史消息将永久丢失。';

  @override
  String get confirmSSSSKeyStored => '密钥已存储';

  @override
  String get yourCurrentDevice => '您当前的设备';

  @override
  String get moveClientTooltip => '移动到此处';

  @override
  String get displayName => '显示名称';

  @override
  String get yourDisplayName => '您的显示名称';

  @override
  String get displayNameHint => '此名称将显示在您的公开资料上。';

  @override
  String get changeDisplayName => '更改显示名称';

  @override
  String get scanQrCode => '扫描二维码';

  @override
  String get compareSas => '比较 SAS 密钥';

  @override
  String get confirmQrScanned => '二维码扫描成功。';

  @override
  String get confirm => '确认';

  @override
  String get scanQrWithOtherDevice => '请用您的其它设备扫描此二维码。';

  @override
  String get clientSwitcher => '切换账号';

  @override
  String get block => '屏蔽';

  @override
  String get unblock => '取消屏蔽';

  @override
  String get sessions => '会话';
}
