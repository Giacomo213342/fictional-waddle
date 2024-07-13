import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

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
  String get authenticationRequired => 'Identitetsbekreftelse påkrevd';

  @override
  String authenticateForAccount(Object mxid) {
    return 'Bekreft din identitet med detaljene tilhørende $mxid.';
  }

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
  String filesSelected(int files) {
    String _temp0 = intl.Intl.pluralLogic(
      files,
      locale: localeName,
      other: '$files files',
      one: 'Én fil',
      zero: 'Ingen filer',
    );
    return '$_temp0 valgt. Filsending støttes ikke enda.';
  }

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
}
