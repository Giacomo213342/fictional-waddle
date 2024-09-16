import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get appName => '';

  @override
  String get about => '';

  @override
  String author(String author) {
    return '';
  }

  @override
  String get appSlogan => '';

  @override
  String get repoLabel => '';

  @override
  String get releaseNotes => '';

  @override
  String get buyMeACoffee => '';

  @override
  String get homeserverHeadline => '';

  @override
  String get aMatrixClient => '';

  @override
  String get connectToHomeserver => '';

  @override
  String get discoverHomeservers => '';

  @override
  String get newToMatrixLong => '';

  @override
  String get connect => '';

  @override
  String get homeserverNotValid => '';

  @override
  String get pleaseProvideHomeserver => '';

  @override
  String errorConnectingToHomeserver(String homeserver) {
    return '';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return '';
  }

  @override
  String welcomeToHomeserver(String homeserver) {
    return '';
  }

  @override
  String get howWouldYouLikeToConnect => '';

  @override
  String get loginPassword => '';

  @override
  String get username => '';

  @override
  String get email => '';

  @override
  String get password => '';

  @override
  String get pleaseProvideEmail => '';

  @override
  String get pleaseProvidePassword => '';

  @override
  String get pleaseProvideUsername => '';

  @override
  String get emailMinimals => '';

  @override
  String get mxidSyntax => '';

  @override
  String clientDisplayName(String platform) {
    return '';
  }

  @override
  String get platformWeb => '';

  @override
  String get loginError => '';

  @override
  String loginErrorMessage(String message) {
    return '';
  }

  @override
  String hajUser(String? localpart) {
    return '';
  }

  @override
  String get syncInProgress => '';

  @override
  String get initialSync => '';

  @override
  String get syncOffline => '';

  @override
  String get syncFunctional => '';

  @override
  String lastSyncReceived(DateTime timestamp, Object duration) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jms(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return '';
  }

  @override
  String editedToday(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jm(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return '';
  }

  @override
  String editedAt(String timestamp) {
    return '';
  }

  @override
  String get authenticationRequired => '';

  @override
  String authenticateForAccount(Object mxid) {
    return '';
  }

  @override
  String replyUserSentDate(Object username, Object formattedDate) {
    return '';
  }

  @override
  String get view => '';

  @override
  String get passphraseNotEmpty => '';

  @override
  String get cancel => '';

  @override
  String get noMatch => '';

  @override
  String get keysMatch => '';

  @override
  String get wipeAccount => '';

  @override
  String get wipeAccountWarning => '';

  @override
  String get deleteAll => '';

  @override
  String get previous => '';

  @override
  String get next => '';

  @override
  String get connectPreviousDevice => '';

  @override
  String get connectPreviousDeviceLong => '';

  @override
  String get deviceNotAvailable => '';

  @override
  String get compareSasNumbers => '';

  @override
  String get compareSasExplanation => '';

  @override
  String get incomingVerificationRequest => '';

  @override
  String get waitingForVerification => '';

  @override
  String get waitingForVerificationFallback => '';

  @override
  String incomingVerificationRequestUser(String? user) {
    return '';
  }

  @override
  String get incomingVerificationRequestMyself => '';

  @override
  String get incomingVerificationRequestLong => '';

  @override
  String get reject => '';

  @override
  String get proceed => '';

  @override
  String get enterRecoveryPhrase => '';

  @override
  String get keyVerificationErrorGeneric => '';

  @override
  String get keyVerificationErrorUser => '';

  @override
  String get close => '';

  @override
  String get verificationSuccessful => '';

  @override
  String get verifyLogin => '';

  @override
  String get finish => '';

  @override
  String get or => '';

  @override
  String get verifyWithOtherDevice => '';

  @override
  String get verifyMethodsNotAvailable => '';

  @override
  String get resetAccountWarning => '';

  @override
  String get verifyWithPassphrase => '';

  @override
  String get passphraseNoWhitespace => '';

  @override
  String get errorTryAgain => '';

  @override
  String get submit => '';

  @override
  String get togglePassword => '';

  @override
  String get loggingInToClient => '';

  @override
  String get pendingInvite => '';

  @override
  String get invite => '';

  @override
  String inviteLongRoom(String roomname) {
    return '';
  }

  @override
  String inviteLongDM(Object displayname) {
    return '';
  }

  @override
  String roomParticipants(int participants) {
    return '';
  }

  @override
  String get joinRoom => '';

  @override
  String get knockRoom => '';

  @override
  String get youCannotJoinThisRoom => '';

  @override
  String get addAccount => '';

  @override
  String get regionAccountSwitcher => '';

  @override
  String get regionChatContents => '';

  @override
  String get loadingHomeservers => '';

  @override
  String get send => '';

  @override
  String get typeGroupImages => '';

  @override
  String get typeGroupVideos => '';

  @override
  String get typeGroupAudio => '';

  @override
  String get typeGroupFiles => '';

  @override
  String get msgTypeText => '';

  @override
  String get msgTypeEmote => '';

  @override
  String get msgTypeNotice => '';

  @override
  String get msgTypeImage => '';

  @override
  String get msgTypeVideo => '';

  @override
  String get msgTypeAudio => '';

  @override
  String get msgTypeFile => '';

  @override
  String get msgTypeLocation => '';

  @override
  String get msgTypeSticker => '';

  @override
  String get msgTypeBadEncrypted => '';

  @override
  String get msgTypeNone => '';

  @override
  String sendingFiles(int files) {
    return '';
  }

  @override
  String get noFilesSelected => '';

  @override
  String get yesterday => '';

  @override
  String get thisMonth => '';

  @override
  String get lastMonth => '';

  @override
  String get download => '';

  @override
  String get share => '';

  @override
  String get saveAs => '';

  @override
  String get settings => '';

  @override
  String get errorDownloadingAttachment => '';

  @override
  String get retry => '';

  @override
  String get searchPromptLabel => '';

  @override
  String get appearanceAccessibilitySettings => '';

  @override
  String get polyculeSettings => '';

  @override
  String get systemLanguage => '';

  @override
  String get language => '';

  @override
  String get theme => '';

  @override
  String get dark => '';

  @override
  String get light => '';

  @override
  String get systemTheme => '';

  @override
  String get fontAccessibility => '';

  @override
  String get inclusiveSans => '';

  @override
  String get openDyslexic => '';

  @override
  String get serif => '';

  @override
  String get defaultFont => '';

  @override
  String get color => '';

  @override
  String get systemColor => '';

  @override
  String get defaultColor => '';

  @override
  String get customColor => '';

  @override
  String get highContrast => '';

  @override
  String get aboutPolycule => '';

  @override
  String contentNotice(String notice) {
    return '';
  }

  @override
  String get contentNoticeFallback => '';

  @override
  String get webUriHandlerTitle => '';

  @override
  String jumpToMessage(String message) {
    return '';
  }

  @override
  String get selectAccount => '';

  @override
  String sharingFiles(int files) {
    return '';
  }

  @override
  String get sharingText => '';

  @override
  String get sendFiles => '';

  @override
  String get checkingTotalSendSize => '';

  @override
  String totalSendSize(int size) {
    return '';
  }

  @override
  String fileSize(int size) {
    return '';
  }

  @override
  String mimeType(String? mimeType) {
    return '';
  }

  @override
  String matrixRoomShareSubject(String roomname) {
    return '';
  }

  @override
  String fileDownloadedTo(String name) {
    return '';
  }

  @override
  String get openFile => '';

  @override
  String get compressFiles => '';

  @override
  String get compressFilesSubtitle => '';

  @override
  String get cancelSending => '';

  @override
  String get retrySending => '';

  @override
  String get accountSettings => '';

  @override
  String get previewRoom => '';

  @override
  String get joinMatrixCall => '';

  @override
  String matrixCallTooltip(String roomId) {
    return '';
  }

  @override
  String get pushSettings => '';

  @override
  String get unifiedPushUnavailable => '';

  @override
  String get selectPushDistributor => '';

  @override
  String get disablePushNotifications => '';

  @override
  String get pushInformationPolycule => '';

  @override
  String get unifiedPushAbout => '';

  @override
  String get unifiedPushLink => '';

  @override
  String get setupUnifiedPush => '';

  @override
  String get googleFirebase => '';

  @override
  String get newNotification => '';

  @override
  String get pushChannelName => '';

  @override
  String get directChats => '';

  @override
  String get groups => '';

  @override
  String get unifiedPush => '';
}
