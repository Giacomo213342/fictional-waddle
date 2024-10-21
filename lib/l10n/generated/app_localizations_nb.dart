import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Norwegian Bokmål (`nb`).
class AppLocalizationsNb extends AppLocalizations {
  AppLocalizationsNb([String locale = 'nb']) : super(locale);

  @override
  String get appName => '< polycule >';

  @override
  String get about => 'Om';

  @override
  String author(String author) {
    return 'Utviklet av $author';
  }

  @override
  String get appSlogan =>
      'En nerdete og effektiv [matrix]-klient for superbrukere.';

  @override
  String get repoLabel => 'Kildekode (GitLab)';

  @override
  String get releaseNotes => 'Utgivelsesnotater';

  @override
  String get buyMeACoffee => 'Spander drikke';

  @override
  String get homeserverHeadline => 'Heihei. Velkommen til < polycule >';

  @override
  String get aMatrixClient => '- enda en [matrix]-klient';

  @override
  String get connectToHomeserver => 'Koble til din hjemmetjener';

  @override
  String get discoverHomeservers => 'Oppdag nye hjemmetjenere';

  @override
  String get newToMatrixLong =>
      'Finn passende hjemmetjenere i [matrix]-universet. Dette kobler til joinmatrix.org.';

  @override
  String get connect => 'Koble til';

  @override
  String get homeserverNotValid => 'Angi en gyldig hjemmetjener.';

  @override
  String get pleaseProvideHomeserver => 'Angi en hjemmetjener.';

  @override
  String errorConnectingToHomeserver(String homeserver) {
    return 'Kunne ikke koble til $homeserver-hjemmetjeneren. Sjekk hva du valgte.';
  }

  @override
  String connectingToHomeserver(String homeserver) {
    return 'Kobler til $homeserver …';
  }

  @override
  String welcomeToHomeserver(String homeserver) {
    return 'Velkommen til $homeserver.';
  }

  @override
  String get howWouldYouLikeToConnect => 'Hvordan ønsker du å koble til?';

  @override
  String get loginPassword => 'Logg inn med passord';

  @override
  String get username => 'brukernavn';

  @override
  String get email => 'e-post';

  @override
  String get password => 'passord';

  @override
  String get pleaseProvideEmail => 'Angi din e-postadresse.';

  @override
  String get pleaseProvidePassword => 'Skriv inn passordet ditt.';

  @override
  String get pleaseProvideUsername => 'Skriv inn brukernavnet ditt.';

  @override
  String get emailMinimals =>
      'E-postadressen din må inneholde et brukernavn, et «@»-symbol, og domenet ditt.';

  @override
  String get mxidSyntax =>
      'Tillatte tegn: a-z, 0–9 og symbolene «., _, =, -, /,+»';

  @override
  String clientDisplayName(String platform) {
    return '< polycule > på $platform';
  }

  @override
  String get platformWeb => 'veven';

  @override
  String get loginError =>
      'Kunne ikke logge inn. Sjekk identitetsdetaljene dine.';

  @override
  String loginErrorMessage(String message) {
    return 'Kunne ikke logge inn: $message';
  }

  @override
  String hajUser(String? localpart) {
    return 'Heihei $localpart.';
  }

  @override
  String get syncInProgress => 'Synkroniserer …';

  @override
  String get initialSync => 'Opprinnelig synkronisering …';

  @override
  String get syncOffline => 'Synkronisering forstyrret';

  @override
  String get syncFunctional => 'Synkronisert';

  @override
  String lastSyncReceived(DateTime timestamp, Object duration) {
    final intl.DateFormat timestampDateFormat = intl.DateFormat.jms(localeName);
    final String timestampString = timestampDateFormat.format(timestamp);

    return 'Siste synkronisering: $timestampString ($duration ms)';
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
  String get authenticationRequired => 'Identitetsbekreftelse påkrevd';

  @override
  String authenticateForAccount(Object mxid) {
    return 'Bekreft din identitet med detaljene tilhørende $mxid.';
  }

  @override
  String replyUserSentDate(Object username, Object formattedDate) {
    return '$username wrote $formattedDate :';
  }

  @override
  String get view => 'View';

  @override
  String get passphraseNotEmpty => 'Du må skrive inn et passord';

  @override
  String get cancel => 'Avbryt';

  @override
  String get noMatch => 'Samsvarer ikke';

  @override
  String get keysMatch => 'Samsvarer';

  @override
  String get wipeAccount => 'Slett konto';

  @override
  String get wipeAccountWarning =>
      'Har du mistet enheten din kan du tømme og tilbakestille kontoen din. Alle meldinger og sludringer vil gå tapt.';

  @override
  String get deleteAll => 'Slett alt';

  @override
  String get previous => 'Forrige';

  @override
  String get next => 'Neste';

  @override
  String get connectPreviousDevice => 'Koble til forrige enhet';

  @override
  String get connectPreviousDeviceLong => 'Bekreft eksisterende enhet.';

  @override
  String get deviceNotAvailable => 'Jeg har ikke tilgang til enheten min.';

  @override
  String get compareSasNumbers => 'Sammenlign sikkerhetsnummer';

  @override
  String get compareSasExplanation =>
      'Sjekk at nummerne på enheten din samsvarer med dem på enheten som forespør bekreftelse.';

  @override
  String get incomingVerificationRequest =>
      'Innkommende bekreftelsesforespørsel';

  @override
  String get waitingForVerification => 'Venter på bekreftelse …';

  @override
  String get waitingForVerificationFallback =>
      'Bekreft med din andre enhet, eller skriv inn gjenopprettelsespassordet.';

  @override
  String incomingVerificationRequestUser(String? user) {
    return '$user ønsker å bekrefte';
  }

  @override
  String get incomingVerificationRequestMyself =>
      'En annen enhet forespurte bekreftelse.';

  @override
  String get incomingVerificationRequestLong =>
      'Håndter innkommende bekreftelsesforespørsel nå?';

  @override
  String get reject => 'Avslå';

  @override
  String get proceed => 'Fortsett';

  @override
  String get enterRecoveryPhrase => 'Skriv inn gjenopprettingspassord';

  @override
  String get keyVerificationErrorGeneric => 'Kunne ikke bekrefte enheten din.';

  @override
  String get keyVerificationErrorUser => 'Bekreftelsen ble avslått.';

  @override
  String get close => 'Lukk';

  @override
  String get verificationSuccessful => 'Tast bekreftet';

  @override
  String get verifyLogin => 'Bekreft din nye innlogging';

  @override
  String get finish => 'Fullfør';

  @override
  String get or => 'eller';

  @override
  String get verifyWithOtherDevice => 'Bekreft med annen enhet';

  @override
  String get verifyMethodsNotAvailable =>
      'Ingen identitetsbekreftelsesmetode tilgjengelig?';

  @override
  String get resetAccountWarning =>
      'You will use all your past messages. This cannot be undone.';

  @override
  String get verifyWithPassphrase => 'Bekreft med passord';

  @override
  String get passphraseNoWhitespace =>
      'Passordet kan ikke inneholde blanktegn.';

  @override
  String get errorTryAgain => 'Noe gikk galt. Prøv igjen.';

  @override
  String get submit => 'send inn';

  @override
  String get togglePassword => 'Veksle passordsynlighet';

  @override
  String get loggingInToClient => 'Logg inn på konto';

  @override
  String get pendingInvite => 'Ventende invitasjon';

  @override
  String get invite => 'Invitasjon';

  @override
  String inviteLongRoom(String roomname) {
    return 'Du er invitert til å ta del i rommet «$roomname».';
  }

  @override
  String inviteLongDM(Object displayname) {
    return 'Du er invitert til å diskutere med « $displayname ».';
  }

  @override
  String roomParticipants(int participants) {
    String _temp0 = intl.Intl.pluralLogic(
      participants,
      locale: localeName,
      other: '$participants deltagere',
      one: 'Én deltager',
      zero: 'Ingen deltagere',
    );
    return '$_temp0';
  }

  @override
  String get joinRoom => 'Ta del i rommet';

  @override
  String get knockRoom => 'Bank på for å ta del';

  @override
  String get youCannotJoinThisRoom => 'Du kan ikke ta del i dette rommet.';

  @override
  String get addAccount => 'Legg til enda en konto';

  @override
  String get regionAccountSwitcher => 'Skjermområde: Kontobytter';

  @override
  String get regionChatContents => 'Skjermområde: sludringsinnhold.';

  @override
  String get loadingHomeservers =>
      'Laster inn hjemmetjenere … Ukjent framdrift. Vent …';

  @override
  String get send => 'Send';

  @override
  String get typeGroupImages => 'Bilder';

  @override
  String get typeGroupVideos => 'Videoer';

  @override
  String get typeGroupAudio => 'Lyd';

  @override
  String get typeGroupFiles => 'Alle filer';

  @override
  String get msgTypeText => 'Send en vanlig tekstmelding.';

  @override
  String get msgTypeEmote => 'Beskriv humøret ditt.';

  @override
  String get msgTypeNotice =>
      'Send en informativ melding botter ikke kan besvare.';

  @override
  String get msgTypeImage => 'Send en bildefil.';

  @override
  String get msgTypeVideo => 'Send en videofil.';

  @override
  String get msgTypeAudio => 'Send en lydfil.';

  @override
  String get msgTypeFile => 'Send en fil.';

  @override
  String get msgTypeLocation => 'Del din posisjon.';

  @override
  String get msgTypeSticker => 'Send et klistremerke.';

  @override
  String get msgTypeBadEncrypted =>
      'Irriter motparten med en melding vedkommende ikke kan dekryptere.';

  @override
  String get msgTypeNone => 'Ikke send noen melding.';

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
  String get yesterday => 'I går';

  @override
  String get thisMonth => 'Denne måneden';

  @override
  String get lastMonth => 'Forrige måned';

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
}
