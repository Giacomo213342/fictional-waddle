import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appName => '<பாலிகுல்>';

  @override
  String get about => 'பற்றி';

  @override
  String author(String author) {
    return 'ஆசிரியர்: $author';
  }

  @override
  String get appSlogan =>
      'ஆற்றல் பயனர்களுக்கான அழகற்ற மற்றும் திறமையான [மேட்ரிக்ச்] கிளையன்ட்.';

  @override
  String get repoLabel => 'மூலக் குறியீடு (கிட்லாப்)';

  @override
  String get releaseNotes => 'வெளியீட்டு குறிப்புகள்';

  @override
  String get buyMeACoffee => 'எனக்கு ஒரு காபி வாங்கவும்';

  @override
  String get homeserverHeadline => 'ஆச்! <பாலிகுல்> க்கு வருக';

  @override
  String get aMatrixClient => '- மற்றொரு [மேட்ரிக்ச்] கிளையன்ட்';

  @override
  String get connectToHomeserver => 'உங்கள் ஓம்சர்வருடன் இணைக்கவும்';

  @override
  String get discoverHomeservers => 'புதிய ஓம்சர்சர்களைக் கண்டறியவும்';

  @override
  String get newToMatrixLong =>
      '[மேட்ரிக்ச்] பிரபஞ்சத்திலிருந்து தகுதியான ஓம்சர்சர்களைக் கண்டறியவும். இது Joinmatrix.org உடன் இணைக்கும்.';

  @override
  String get connect => 'இணை';

  @override
  String get homeserverNotValid =>
      'இது செல்லுபடியாகும் ஓம்சர்வர் உள்ளீடு அல்ல.';

  @override
  String get pleaseProvideHomeserver => 'தயவுசெய்து ஒரு ஓம்சரவரை வழங்கவும்.';

  @override
  String errorConnectingToHomeserver(String homeserver) {
    return '$homeserver இணைக்க முடியவில்லை. உங்கள் தேர்வை சரிபார்க்கவும்.';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return '$homeserver உடன் இணைக்கிறது…';
  }

  @override
  String welcomeToHomeserver(String homeserver) {
    return '$homeserver க்கு வருக!';
  }

  @override
  String get howWouldYouLikeToConnect =>
      'நீங்கள் எவ்வாறு இணைக்க விரும்புகிறீர்கள்?';

  @override
  String get loginPassword => 'கடவுச்சொல்லைப் பயன்படுத்தி உள்நுழைக';

  @override
  String get username => 'பயனர்பெயர்';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get pleaseProvideEmail => 'உங்கள் மின்னஞ்சலை வழங்கவும்.';

  @override
  String get pleaseProvidePassword => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get pleaseProvideUsername => 'உங்கள் பயனர்பெயரை உள்ளிடவும்.';

  @override
  String get emailMinimals =>
      'உங்கள் மின்னஞ்சலில் @ அடையாளம், உள்ளக பகுதி மற்றும் உங்கள் டொமைன் இருக்க வேண்டும்.';

  @override
  String get mxidSyntax =>
      'அனுமதிக்கப்பட்ட எழுத்துக்கள்: A-Z, 0-9 மற்றும் சின்னங்கள்., _, =,-, /, மற்றும் +.';

  @override
  String clientDisplayName(String platform) {
    return '<பாலிகுல்> $platform';
  }

  @override
  String get platformWeb => 'விரலிடைத் தோல்';

  @override
  String get loginError =>
      'உள்நுழைய முடியவில்லை; உங்கள் சான்றுகளை சரிபார்க்கவும்.';

  @override
  String loginErrorMessage(String message) {
    return 'உள்நுழைய முடியவில்லை: $message';
  }

  @override
  String hajUser(String? localpart) {
    return 'அச் $localpart!';
  }

  @override
  String get syncInProgress => 'முன்னேற்றத்தில் ஒத்திசைக்கவும்';

  @override
  String get initialSync => 'ஆரம்ப ஒத்திசைவு செயலில் உள்ளது';

  @override
  String get syncOffline => 'ஒத்திசைவு குறுக்கிட்டது';

  @override
  String get syncFunctional => 'நிலை ஆரோக்கியமாக ஒத்திசைக்கவும்';

  @override
  String lastSyncReceived(DateTime timestamp, Object duration) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jms(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return 'கடைசி ஒத்திசைவு: $timestampString ($duration எம்.எச்)';
  }

  @override
  String editedToday(DateTime timestamp) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jm(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return 'திருத்தப்பட்டது: $timestampString';
  }

  @override
  String editedAt(String timestamp) {
    return 'திருத்தப்பட்டது: $timestamp';
  }

  @override
  String get authenticationRequired => 'ஏற்பு தேவை';

  @override
  String authenticateForAccount(Object mxid) {
    return '$mxid க்கான உங்கள் சான்றுகளுடன் அங்கீகரிக்கவும்.';
  }

  @override
  String replyUserSentDate(Object username, Object formattedDate) {
    return '$username எழுதியது $formattedDate:';
  }

  @override
  String get view => 'பார்வை';

  @override
  String get passphraseNotEmpty => 'கடவுச்சொல் காலியாக இருக்க முடியாது';

  @override
  String get cancel => 'ரத்துசெய்';

  @override
  String get noMatch => 'பொருந்தவில்லை';

  @override
  String get keysMatch => 'விசைகள் பொருந்துகின்றன';

  @override
  String get wipeAccount => 'கணக்கை துடைக்கவும்';

  @override
  String get wipeAccountWarning =>
      'உங்கள் சாதனத்தை இழந்தால், உங்கள் கணக்கை துடைத்து மீட்டமைக்கலாம். எல்லா செய்திகளும் அரட்டைகளும் இழக்கப்படும்.';

  @override
  String get deleteAll => 'அனைத்தையும் நீக்கு';

  @override
  String get previous => 'முந்தைய';

  @override
  String get next => 'அடுத்தது';

  @override
  String get connectPreviousDevice => 'முந்தைய சாதனத்தை இணைக்கவும்';

  @override
  String get connectPreviousDeviceLong => 'இருக்கும் சாதனத்தை சரிபார்க்கவும்.';

  @override
  String get deviceNotAvailable => 'எனது சாதனம் கிடைக்கவில்லை.';

  @override
  String get compareSasNumbers => 'பாதுகாப்பு எண்களை ஒப்பிடுக';

  @override
  String get compareSasExplanation =>
      'உங்கள் சாதனத்தில் உள்ள எண்கள் சரிபார்ப்பைக் கோரும் மற்ற சாதனத்தின் எண்களுடன் ஒத்ததா என்று சரிபார்க்கவும்.';

  @override
  String get incomingVerificationRequest => 'உள்வரும் சரிபார்ப்பு கோரிக்கை';

  @override
  String get waitingForVerification => 'சரிபார்ப்புக்காக காத்திருக்கிறது';

  @override
  String get waitingForVerificationFallback =>
      'உங்கள் இரண்டாவது சாதனத்தைப் பயன்படுத்துவதை சரிபார்க்கவும் அல்லது உங்கள் மீட்பு சொற்றொடரை உள்ளிடவும்.';

  @override
  String incomingVerificationRequestUser(String? user) {
    return '$user சரிபார்க்க விரும்புகிறார்';
  }

  @override
  String get incomingVerificationRequestMyself =>
      'உங்கள் கணக்கிற்கான மற்றொரு சாதனத்தை சரிபார்க்க உள்வரும் சரிபார்ப்பு கோரிக்கை உள்ளது.';

  @override
  String get incomingVerificationRequestLong =>
      'உள்வரும் சரிபார்ப்பு கோரிக்கை உள்ளது, சரிபார்ப்பு கோரிக்கையை கையாள விரும்புகிறீர்களா?';

  @override
  String get reject => 'நிராகரிக்கவும்';

  @override
  String get proceed => 'தொடரவும்';

  @override
  String get enterRecoveryPhrase => 'மீட்பு சொற்றொடரை உள்ளிடவும்';

  @override
  String get keyVerificationErrorGeneric =>
      'உங்கள் சாதனத்தை சரிபார்க்க பிழை ஏற்பட்டது.';

  @override
  String get keyVerificationErrorUser => 'சரிபார்ப்பு நிராகரிக்கப்பட்டது.';

  @override
  String get close => 'மூடு';

  @override
  String get verificationSuccessful => 'முக்கிய சரிபார்ப்பு வெற்றிகரமாக';

  @override
  String get verifyLogin => 'உங்கள் புதிய உள்நுழைவை சரிபார்க்கவும்';

  @override
  String get finish => 'முடிக்க';

  @override
  String get or => 'அல்லது';

  @override
  String get verifyWithOtherDevice => 'மற்ற சாதனங்களுடன் சரிபார்க்கவும்';

  @override
  String get verifyMethodsNotAvailable =>
      'உங்களிடம் சரிபார்ப்பு முறை கிடைக்கவில்லையா?';

  @override
  String get resetAccountWarning =>
      'உங்கள் கடந்த கால செய்திகளையும் பயன்படுத்துவீர்கள். இதை செயல்தவிர்க்க முடியாது.';

  @override
  String get verifyWithPassphrase => 'கடவுச்சொற்றுடன் சரிபார்க்கவும்';

  @override
  String get passphraseNoWhitespace =>
      'பாச்ஃபிரேசில் எந்த இடைவெளி எழுத்துக்களும் இருக்க முடியாது!';

  @override
  String get errorTryAgain => 'பிழை ஏற்பட்டது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get submit => 'சமர்ப்பிக்கவும்';

  @override
  String get togglePassword => 'கடவுச்சொல் தெரிவுநிலையை மாற்றவும்';

  @override
  String get loggingInToClient => 'கணக்கில் உள்நுழைக';

  @override
  String get pendingInvite => 'அழைப்பு நிலுவையில்';

  @override
  String get invite => 'அழைக்கவும்';

  @override
  String inviteLongRoom(String roomname) {
    return 'அறையில் சேர நீங்கள் அழைக்கப்படுகிறீர்கள்: « $roomname ».';
  }

  @override
  String inviteLongDM(Object displayname) {
    return '«$displayname» உடன் விவாதிக்க அழைக்கப்படுகிறீர்கள்.';
  }

  @override
  String roomParticipants(int participants) {
    String _temp0 = intl.Intl.pluralLogic(
      participants,
      locale: localeName,
      other: '$participants பங்கேற்பாளர்கள்',
      one: 'ஒரு பங்கேற்பாளர்',
      zero: 'பங்கேற்பாளர் இல்லை',
    );
    return '$_temp0';
  }

  @override
  String get joinRoom => 'அறையில் சேரவும்';

  @override
  String get knockRoom => 'சேர தட்டவும்';

  @override
  String get youCannotJoinThisRoom => 'இந்த அறையில் நீங்கள் சேர முடியாது.';

  @override
  String get addAccount => 'மற்றொரு கணக்கைச் சேர்க்கவும்';

  @override
  String get regionAccountSwitcher => 'திரை பகுதி: கணக்கு ச்விட்சர்.';

  @override
  String get regionChatContents => 'திரை பகுதி: அரட்டை உள்ளடக்கம்.';

  @override
  String get loadingHomeservers =>
      'ஓம்சர்வர்களை ஏற்றுகிறது. முன்னேற்றம் தெரியவில்லை. தயவுசெய்து காத்திருங்கள்.';

  @override
  String get send => 'அனுப்பு';

  @override
  String get typeGroupImages => 'படங்கள்';

  @override
  String get typeGroupVideos => 'வீடியோக்கள்';

  @override
  String get typeGroupAudio => 'ஆடியோ';

  @override
  String get typeGroupFiles => 'அனைத்து கோப்புகள்';

  @override
  String get msgTypeText => 'வழக்கமான உரை செய்தியை அனுப்பவும்.';

  @override
  String get msgTypeEmote => 'உங்கள் மனநிலையை விவரிக்கவும்.';

  @override
  String get msgTypeNotice =>
      'ஒரு தகவலறிந்த செய்தியை அனுப்பவும் போட்ச் பதிலளிக்க முடியாது.';

  @override
  String get msgTypeImage => 'படக் கோப்பை அனுப்பவும்.';

  @override
  String get msgTypeVideo => 'வீடியோ கோப்பை அனுப்பவும்.';

  @override
  String get msgTypeAudio => 'ஆடியோ கோப்பை அனுப்பவும்.';

  @override
  String get msgTypeFile => 'ஒரு கோப்பை அனுப்பவும்.';

  @override
  String get msgTypeLocation => 'உங்கள் இருப்பிடத்தைப் பகிரவும்.';

  @override
  String get msgTypeSticker => 'ஒரு ச்டிக்கரை அனுப்பவும்.';

  @override
  String get msgTypeBadEncrypted =>
      'அவர்கள் மறைகுறியாக்க முடியாத ஒரு செய்தியுடன் உங்கள் சகாக்களை எரிச்சலூட்டுங்கள்.';

  @override
  String get msgTypeNone => 'எந்த செய்தியும் அனுப்பவும்.';

  @override
  String sendingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files கோப்புகள்',
      one: 'ஒரு கோப்பு',
      zero: 'அனுப்ப கோப்பு இல்லை.',
    );
    return '$_temp0 அனுப்புதல்...';
  }

  @override
  String get noFilesSelected => 'கோப்புகள் எதுவும் தேர்ந்தெடுக்கப்படவில்லை.';

  @override
  String get yesterday => 'நேற்று';

  @override
  String get thisMonth => 'இந்த மாதம்';

  @override
  String get lastMonth => 'கடந்த மாதம்';

  @override
  String get download => 'பதிவிறக்கம்';

  @override
  String get share => 'பங்கு';

  @override
  String get saveAs => 'என சேமி';

  @override
  String get settings => 'அமைப்புகள்';

  @override
  String get errorDownloadingAttachment =>
      'செய்தி இணைப்பைப் பதிவிறக்குவதில் பிழை.';

  @override
  String get retry => 'மீண்டும் முயற்சிக்கவும்';

  @override
  String get searchPromptLabel => 'கட்டளை, பயனர், அறை பெயர் அல்லது MXID';

  @override
  String get appearanceAccessibilitySettings => 'தோற்றம் மற்றும் அணுகல்';

  @override
  String get polyculeSettings => 'உங்கள் <பாலிகுல்> உள்ளமைக்கவும்';

  @override
  String get systemLanguage => 'சாதன மொழி';

  @override
  String get language => 'மொழி';

  @override
  String get theme => 'கருப்பொருள்';

  @override
  String get dark => 'இருண்ட முனையம்';

  @override
  String get light => 'ஒளி ரோசா';

  @override
  String get systemTheme => 'கணினி கருப்பொருள்';

  @override
  String get fontAccessibility => 'எழுத்துரு அணுகல்';

  @override
  String get inclusiveSans => 'அதிகரித்த வாசிப்பு எழுத்துரு';

  @override
  String get openDyslexic => 'டிச்லெக்சியா-உதவி எழுத்துரு';

  @override
  String get serif => 'செரிஃப் எழுத்துரு';

  @override
  String get defaultFont => 'இயல்புநிலை எழுத்துரு';

  @override
  String get color => 'வண்ண அமைப்புகள்';

  @override
  String get systemColor => 'கணினி நிறம்';

  @override
  String get defaultColor => 'கருப்பொருள் இயல்புநிலை நிறம்';

  @override
  String get customColor => 'தனிப்பயன் நிறம்';

  @override
  String get highContrast => 'உயர் வேறுபாடு';

  @override
  String get aboutPolycule => '<பாலிகுல்> பற்றி';

  @override
  String contentNotice(String notice) {
    return 'சி.என்: «$notice»';
  }

  @override
  String get contentNoticeFallback => 'உள்ளடக்க அறிவிப்பு';

  @override
  String get webUriHandlerTitle => '<பாலிகுல்> [மேட்ரிக்ச்] வாடிக்கையாளர்';

  @override
  String jumpToMessage(String message) {
    return 'செய்திக்கு செல்லவும் $message';
  }

  @override
  String get selectAccount => 'தொடர கணக்கைத் தேர்ந்தெடுக்கவும்';

  @override
  String sharingFiles(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files கோப்புகள்',
      one: 'ஒரு கோப்பு',
    );
    return '$_temp0 அனுப்புகிறது.';
  }

  @override
  String get sharingText => 'உரையை அறைக்கு பகிரவும்';

  @override
  String get sendFiles => 'கோப்புகளை அனுப்பவும்';

  @override
  String get checkingTotalSendSize => 'மொத்த அனுப்பும் அளவை சரிபார்க்கிறது ...';

  @override
  String totalSendSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'மொத்த அனுப்பு அளவு: $size பைட்டுகள்',
      one: 'மொத்த அனுப்பு அளவு : 1 பைட்',
      zero: 'மொத்த அனுப்பு அளவு : 0 பைட்டுகள்',
    );
    return '$_temp0';
  }

  @override
  String fileSize(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'கோப்பு அளவு: $size பைட்டுகள்',
      one: 'கோப்பு அளவு : 1 பைட்',
      zero: 'கோப்பு அளவு : 0 பைட்டுகள்',
    );
    return '$_temp0';
  }

  @override
  String mimeType(String? mimeType) {
    return 'கோப்பு வகை: $mimeType';
  }

  @override
  String matrixRoomShareSubject(String roomname) {
    return '[மேட்ரிக்ச்] இல் «$roomname »அறையில் சேரவும்';
  }

  @override
  String matrixUserShareSubject(String mxid) {
    return '[மேட்ரிக்ச்] இல் «$mxid »ஐ தொடர்பு கொள்ளவும்';
  }

  @override
  String fileDownloadedTo(String name) {
    return 'கோப்பு «$name» என சேமிக்கப்பட்டது.';
  }

  @override
  String get openFile => 'திற';

  @override
  String get compressFiles => 'கோப்புகளை சுருக்கவும்';

  @override
  String get compressFilesSubtitle => 'உதவி கோப்பு வகைகளுக்கு மட்டுமே';

  @override
  String get cancelSending => 'அனுப்புவதை ரத்துசெய்';

  @override
  String get retrySending => 'அனுப்புவதை மீண்டும் முயற்சிக்கவும்';

  @override
  String get accountSettings => 'கணக்கு அமைப்புகள்';

  @override
  String get previewRoom => 'விருந்தினராக முன்னோட்டம்';

  @override
  String get joinMatrixCall => 'சேர [மேட்ரிக்ச்] அழைப்பு';

  @override
  String matrixCallTooltip(String roomId) {
    return 'ஐடியை அழைக்கவும்: $roomId';
  }

  @override
  String get pushSettings => 'அறிவிப்புகளை அழுத்தவும்';

  @override
  String get unifiedPushUnavailable =>
      'உங்கள் சாதனத்தில் UNIFIDEPUSH கிடைக்கவில்லை.';

  @override
  String get selectPushDistributor =>
      'உங்கள் ஒருங்கிணைந்த புச் விநியோகச்தரைத் தேர்ந்தெடுக்கவும்';

  @override
  String get disablePushNotifications => 'புச் அறிவிப்புகளை முடக்கு';

  @override
  String get pushInformationPolycule =>
      'தற்போது, <licicule> ஆண்ட்ராய்டு இல் புச் அறிவிப்புகளை மட்டுமே ஆதரிக்கிறது. லினக்ச் உதவி திட்டமிடப்பட்டுள்ளது.';

  @override
  String get unifiedPushAbout =>
      'புச் அறிவிப்புகளுக்கு நீங்கள் ஒரு விநியோகச்தரை நிறுவ வேண்டும்.\n மேலும் தகவல்களை நீங்கள் இங்கு காணலாம்: https://unifiedpush.org/users/intro/';

  @override
  String get unifiedPushLink => 'https://unifiedpush.org/users/intro/';

  @override
  String get setupUnifiedPush => 'அமைவு UNIFIDEPUSH';

  @override
  String get googleFirebase => 'கூகிள் ஃபயர்பேச் முகில் செய்தி';

  @override
  String get newNotification => '<பாலிசீல்> இல் புதிய செய்தி';

  @override
  String get pushChannelName => 'உள்வரும் செய்திகள்';

  @override
  String get directChats => 'நேரடி செய்தி அறைகள்';

  @override
  String get groups => 'குழு அறைகள்';

  @override
  String get unifiedPush => 'UNIFIDEPUSH';

  @override
  String get reply => 'பதில்';

  @override
  String get edit => 'தொகு';

  @override
  String get redact => 'திருத்துதல்';

  @override
  String get copyMessage => 'செய்தியை நகலெடுக்கவும்';

  @override
  String get confirmRedact => 'Redact நிகழ்வு';

  @override
  String redactEventLong(String eventId) {
    return 'நிகழ்வை $eventId ஐ மாற்றியமைக்க நீங்கள் நிரந்தரமாக விரும்புகிறீர்களா?';
  }

  @override
  String get logoutCommandSyntax => 'இந்த கணக்கிலிருந்து வெளியேறுதல்.';

  @override
  String get roomnameCommandSyntax => 'அறை பெயரை [பெயர்] என அமைக்கவும்.';

  @override
  String get roomdescriptionCommandSyntax =>
      'அறை விளக்கத்தை [விளக்கம்] என அமைக்கவும்.';

  @override
  String get sendCommandSyntax => 'உரை செய்தியை அனுப்பவும். [M.Text]';

  @override
  String get meCommandSyntax => 'உங்கள் மனநிலையை விவரிக்கவும். [M.EMOTE]';

  @override
  String get dmCommandSyntax =>
      'ஒரு டி.எம் அறையை உருவாக்கவும். [mxid] [--no-encryption?]';

  @override
  String get createCommandSyntax =>
      'ஒரு அறையை உருவாக்கவும். [பெயர்?] [-இல்லை-உணர்திறன்?]';

  @override
  String get plainCommandSyntax =>
      'மார்க் பேரூர் பாகுபடுத்தாமல் ஒரு குறுஞ்செய்தியை அனுப்பவும். [M.Text]';

  @override
  String get htmlCommandSyntax =>
      'மூல உஉகுமொ இல் ஒரு உரை செய்தியை அனுப்பவும். [M.Text]';

  @override
  String get reactCommandSyntax =>
      'ஒரு எதிர்வினையுடன் பதிலளிக்கவும். [எதிர்வினை]';

  @override
  String get joinCommandSyntax => 'ஒரு அறையில் சேரவும். [MXID]';

  @override
  String get leaveCommandSyntax => 'தற்போதைய அறையை விட்டு விடுங்கள்.';

  @override
  String get opCommandSyntax =>
      'உறுப்பினர் ஆற்றல் மட்டத்தை அமைக்கவும். [MXID] [50?]';

  @override
  String get kickCommandSyntax => 'கிக் உறுப்பினர். [MXID]';

  @override
  String get banCommandSyntax => 'தடை உறுப்பினர். [MXID]';

  @override
  String get unbanCommandSyntax => 'கட்டுப்பாடற்ற உறுப்பினர். [MXID]';

  @override
  String get inviteCommandSyntax => 'உறுப்பினரை அழைக்கவும். [MXID]';

  @override
  String get myroomnickCommandSyntax =>
      'இந்த அறையில் தனிப்பயன் நிக் அமைக்கவும். [காட்சி பெயர்]';

  @override
  String get myroomavatarCommandSyntax =>
      'இந்த அறையில் தனிப்பயன் MXC அவதாரத்தை அமைக்கவும். [MXC]';

  @override
  String get discardsessionCommandSyntax =>
      'உங்கள் வெளிச்செல்லும் அறை அமர்வை நிராகரிக்கவும்.';

  @override
  String get clearcacheCommandSyntax =>
      'கணக்கின் உள்ளக தற்காலிக சேமிப்பை அழிக்கவும்.';

  @override
  String get markasdmCommandSyntax =>
      'தற்போதைய அறையை ஒரு உறுப்பினருடன் டி.எம். [MXID]';

  @override
  String get markasgroupCommandSyntax =>
      'டி.எம் பட்டியலிலிருந்து தற்போதைய அறையை அகற்றவும்.';

  @override
  String get hugCommandSyntax => 'மெய்நிகர் அணைப்புகளை அனுப்பவும்.';

  @override
  String get googlyCommandSyntax => 'மெய்நிகர் கூகிள் கண்களை அனுப்பவும்.';

  @override
  String get cuddleCommandSyntax => 'மெய்நிகர் கட்ல்களை அனுப்பவும்.';

  @override
  String get sendrawCommandSyntax => 'ஒரு மூல நிகழ்வை அனுப்பவும். [உள்ளடக்கம்]';

  @override
  String get ignoreCommandSyntax => 'ஒரு பயனரை புறக்கணிக்கவும். [MXID]';

  @override
  String get unignoreCommandSyntax => 'ஒரு பயனரை இணைக்கவும். [MXID]';

  @override
  String get noErrorReported => 'பிழை எதுவும் தெரிவிக்கப்படவில்லை.';

  @override
  String get commandInvalid => 'இது செல்லுபடியாகாத <பாலிகுல்> கட்டளை அல்ல.';

  @override
  String get commandHelp => 'உதவியைக் காட்டு';

  @override
  String get availableCommands => 'கிடைக்கும் கட்டளைகள்';

  @override
  String get commandError => 'வெளியேறும் குறியீடு 1';

  @override
  String get noStickerPacks =>
      'உங்கள் கணக்கோ அல்லது இந்த அறையோ எந்த ச்டிக்கர் பேக் கிடைக்கவில்லை.';

  @override
  String get react => 'எதிர்வினை அனுப்பவும்';

  @override
  String get logs => 'பயன்பாட்டு பதிவுகள்';

  @override
  String get reload => 'ஏற்றவும்';

  @override
  String get runtimeError => 'உங்கள் <பாலிகுல்> தரமற்றதாக இருந்தது';

  @override
  String get logSingleError => 'அநாமதேயமாக பகிர்ந்து கொள்ளுங்கள்';

  @override
  String get enableSentry => 'எப்போதும் பகிரவும்';

  @override
  String get errorReporting => 'பிழை அறிக்கை';

  @override
  String get errorReportingLong =>
      '<licicule> இல் பிழைகளைக் கண்டறிய உதவும் பிழை அறிக்கையை நீங்கள் இயக்கலாம்.';

  @override
  String get errorReportingPrivacy =>
      'இது <licyle> இன் மூலக் குறியீடு புரவலன் மற்றும் அநாமதேயமாக நிகழும் பிழைகள் மற்றும் அவற்றின் காரணங்களை அநாமதேயமாக பகிர்ந்து கொள்ளும் Gitlab.com உடன் இணைக்கும். இது எந்தவொரு தனிப்பட்ட தரவையும் டெவலப்பருக்கு பகிர்ந்து கொள்ளாது.';

  @override
  String get learnMore => 'மேலும் அறிக';

  @override
  String get gitLabPrivacy =>
      'https://gitlab.com/help/operations/error_tracking.md';

  @override
  String get fontSize => 'எழுத்துரு அளவு';

  @override
  String get reset => 'மீட்டமை';

  @override
  String fontScaleLabel(double scale) {
    final intl.NumberFormat scaleNumberFormat =
        intl.NumberFormat.decimalPercentPattern(
            locale: localeName, decimalDigits: 1);
    final String scaleString = scaleNumberFormat.format(scale);

    return '$scaleString';
  }

  @override
  String get openDirectChat => 'நேரடி அரட்டை திறக்கவும்';

  @override
  String get startDirectChat => 'நேரடி அரட்டையைத் தொடங்கவும்';

  @override
  String get ignoreUser => 'புறக்கணிக்கவும்';

  @override
  String get unignoreUser => 'இணக்கமானவர்';

  @override
  String get ignoreToggleWaiting =>
      'செயலாக்கம் நிலையை புறக்கணிக்கவும். இதற்கு சிறிது நேரம் ஆகும்.';

  @override
  String get roomStateWtf =>
      'இந்த அறையின் பாதுகாப்பு ஒரு குழப்பம். தவிர்க்க சிறந்தது.';

  @override
  String get roomStatePublic => 'இந்த அறை அனைவருக்கும் பகிரங்கமாக தெரியும்';

  @override
  String get roomStatePublicKnock =>
      'இந்த அறை அனைவருக்கும் பகிரங்கமாக தெரியும், ஆனால் அவர்கள் சேருவதற்கு முன்பு தட்ட வேண்டும்.';

  @override
  String get roomStateOpen =>
      'இந்த அறை அதன் இணைப்பை அறிந்த அனைவருக்கும் திறந்திருக்கும்.';

  @override
  String get roomStateKnock =>
      'இந்த அறையில் சேருவதற்கு முன்பு பயனர்கள் தட்ட வேண்டும்.';

  @override
  String get roomStateSpace =>
      'இந்த அறை விண்வெளி உறுப்பினர்களுக்கு மட்டுமே திறந்திருக்கும்.';

  @override
  String get roomStateUnpublic =>
      'இந்த அறை தனிப்பட்டது ஆனால் குறியாக்கம் செய்யப்படவில்லை.';

  @override
  String get roomStateEncrypted =>
      'இந்த அறை குறியாக்கம் செய்யப்பட்டுள்ளது, ஆனால் சில உறுப்பினர்கள் சரிபார்க்கப்படவில்லை.';

  @override
  String get roomStateVerifiedEncrypted =>
      'இந்த அறை குறியாக்கம் செய்யப்பட்டுள்ளது மற்றும் ஒவ்வொரு அமர்வும் குறுக்கு கையெழுத்திட்டது.';

  @override
  String get oidcAppName => '<பாலிகுல்>';

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
  String get loginOidc => 'OpenID இணைப்பைப் பயன்படுத்தி உள்நுழைக';

  @override
  String get oidcConfirm => 'உறுதிப்படுத்தவும்';

  @override
  String get manageSessions => 'அமர்வுகளை நிர்வகிக்கவும்';

  @override
  String get deactivateAccount => 'கணக்கை செயலிழக்கச் செய்யுங்கள்';

  @override
  String get networkSettings => 'பிணைய அமைப்புகள்';

  @override
  String get useSystemProxy => 'சாதன பதிலாள் அமைப்புகளை அனுமதிக்கவும்';

  @override
  String get verifyCertificates => 'TLS சான்றிதழ்களை சரிபார்க்கவும்';

  @override
  String get verifyTlsCertificatesAndroid =>
      'பழைய ஆண்ட்ராய்டு பதிப்புகளுக்கு, சுழற்றப்பட்ட லெட்ச் ஐ.எச்.ஆர்.சி ரூட் ஃச் 1 சான்றிதழ் ஏற்கனவே சேர்க்கப்பட்டுள்ளது.';

  @override
  String get sendTlsSNI => 'எளிய உரை சேவையக பெயர் குறிப்பை அனுப்பவும்';

  @override
  String get minTlsVersion =>
      'ஓம்சர்வர் மூலம் குறைந்தபட்ச தேவையான டி.எல்.எச் பதிப்பு';

  @override
  String get tls12 => 'டி.எல்.எச் 1.2';

  @override
  String get tls13 => 'டி.எல்.எச் 1.3';

  @override
  String get favoriteAdd => 'பிடித்தவைகளில் சேர்க்கவும்';

  @override
  String get favoriteRemove => 'பிடித்தவைகளிலிருந்து அகற்று';

  @override
  String get markRead => 'படித்தபடி குறி';

  @override
  String get markUnread => 'படிக்காத எனக் குறிக்கவும்';

  @override
  String get leaveRoom => 'அறை விடுங்கள்';

  @override
  String leaveRoomLong(String name) {
    return 'அறையை நிரந்தரமாக விட்டுச் செல்லுங்கள் «$name».';
  }

  @override
  String get userDetails => 'பயனர் சுயவிவரத்தைக் காண்க';

  @override
  String get markMute => 'முடக்கு அறை';

  @override
  String get markUnmute => 'ஈடுசெய்யும் அறை';

  @override
  String get copyRoomAddress => 'பொது அறை முகவரியை நகலெடுக்கவும்';

  @override
  String get search => 'தேடல்';

  @override
  String get startVerification => 'சரிபார்ப்பைத் தொடங்கவும்';

  @override
  String get keyVerificationRequestSent =>
      'முக்கிய சரிபார்ப்பு கோரிக்கை அனுப்பப்பட்டது.';

  @override
  String get noHomeserverConnection => 'ஓம்சர்வருக்கு எந்த தொடர்பும் இல்லை.';

  @override
  String get emojiSettings => 'ஈமோசி அமைப்புகள்';

  @override
  String get defaultEmojiTone => 'இயல்புநிலை ஈமோசி தொனி';

  @override
  String get autoplayAnimations =>
      'அனிமேசன் படங்கள் மற்றும் ச்டிக்கர்களை தானாக இயக்கவும்';

  @override
  String get yellowSkin => 'மஞ்சள் தோல்';

  @override
  String get paleSkin => 'வெளிர் தோல்';

  @override
  String get demiPaleSkin => 'அரை வெளிர் தோல்';

  @override
  String get mediumSkin => 'நடுத்தர தோல்';

  @override
  String get brownSkin => 'பழுப்பு தோல்';

  @override
  String get blackSkin => 'கருப்பு தோல்';

  @override
  String get roomDetails => 'அறை விவரங்கள்';

  @override
  String get errorSendingSticker => 'தனிப்பயன் ச்டிக்கரை அனுப்புவதில் பிழை.';

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
}
