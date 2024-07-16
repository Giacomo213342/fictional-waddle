import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart' deferred as app_localizations_de;
import 'app_localizations_en.dart' deferred as app_localizations_en;
import 'app_localizations_nb.dart' deferred as app_localizations_nb;
import 'app_localizations_nl.dart' deferred as app_localizations_nl;

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('nb'),
    Locale('nl')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'< polycule >'**
  String get appName;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @author.
  ///
  /// In en, this message translates to:
  /// **'Author: {author}'**
  String author(String author);

  /// No description provided for @appSlogan.
  ///
  /// In en, this message translates to:
  /// **'A geeky and efficient [matrix] client for power users.'**
  String get appSlogan;

  /// No description provided for @repoLabel.
  ///
  /// In en, this message translates to:
  /// **'Source code (GitLab)'**
  String get repoLabel;

  /// No description provided for @releaseNotes.
  ///
  /// In en, this message translates to:
  /// **'Release notes'**
  String get releaseNotes;

  /// No description provided for @buyMeACoffee.
  ///
  /// In en, this message translates to:
  /// **'Buy me a coffee'**
  String get buyMeACoffee;

  /// Welcome message. The term 'Haj' is a pun from the Blåhaj culture and the English salutation 'hey'.
  ///
  /// In en, this message translates to:
  /// **'Haj ! Welcome to < polycule >'**
  String get homeserverHeadline;

  /// No description provided for @aMatrixClient.
  ///
  /// In en, this message translates to:
  /// **'- yet another [matrix] client'**
  String get aMatrixClient;

  /// No description provided for @connectToHomeserver.
  ///
  /// In en, this message translates to:
  /// **'Connect to your homeserver'**
  String get connectToHomeserver;

  /// No description provided for @discoverHomeservers.
  ///
  /// In en, this message translates to:
  /// **'Discover new homeservers'**
  String get discoverHomeservers;

  /// No description provided for @newToMatrixLong.
  ///
  /// In en, this message translates to:
  /// **'Find eligible homeservers from the [matrix] universe. This will connect to joinmatrix.org.'**
  String get newToMatrixLong;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @homeserverNotValid.
  ///
  /// In en, this message translates to:
  /// **'This is no valid homeserver input.'**
  String get homeserverNotValid;

  /// No description provided for @pleaseProvideHomeserver.
  ///
  /// In en, this message translates to:
  /// **'Please provide a homeserver.'**
  String get pleaseProvideHomeserver;

  /// No description provided for @errorConnectingToHomeserver.
  ///
  /// In en, this message translates to:
  /// **'Could not connect {homeserver}. Please check your selection.'**
  String errorConnectingToHomeserver(String homeserver);

  /// No description provided for @connectingToHomeserver.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {homeserver} …'**
  String connectingToHomeserver(String homeserver);

  /// No description provided for @welcomeToHomeserver.
  ///
  /// In en, this message translates to:
  /// **'Welcome to {homeserver} !'**
  String welcomeToHomeserver(String homeserver);

  /// No description provided for @howWouldYouLikeToConnect.
  ///
  /// In en, this message translates to:
  /// **'How would you like to connect ?'**
  String get howWouldYouLikeToConnect;

  /// No description provided for @loginPassword.
  ///
  /// In en, this message translates to:
  /// **'Login using password'**
  String get loginPassword;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get username;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'password'**
  String get password;

  /// No description provided for @pleaseProvideEmail.
  ///
  /// In en, this message translates to:
  /// **'Please provide your email.'**
  String get pleaseProvideEmail;

  /// No description provided for @pleaseProvidePassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password.'**
  String get pleaseProvidePassword;

  /// No description provided for @pleaseProvideUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username.'**
  String get pleaseProvideUsername;

  /// No description provided for @emailMinimals.
  ///
  /// In en, this message translates to:
  /// **'Your email must least contain the @ symbol, a local part and your domain.'**
  String get emailMinimals;

  /// No description provided for @mxidSyntax.
  ///
  /// In en, this message translates to:
  /// **'Allowed characters : a-z, 0-9 as well as the symbols ., _, =, -, /, and +.'**
  String get mxidSyntax;

  /// Describes the device in the list of devices. The parameter is a localized phrase like `web` or `Linux`.
  ///
  /// In en, this message translates to:
  /// **'< polycule > on {platform}'**
  String clientDisplayName(String platform);

  /// No description provided for @platformWeb.
  ///
  /// In en, this message translates to:
  /// **'web'**
  String get platformWeb;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Could not log in ; please check your credentials.'**
  String get loginError;

  /// No description provided for @loginErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Could not log in : {message}'**
  String loginErrorMessage(String message);

  /// No description provided for @hajUser.
  ///
  /// In en, this message translates to:
  /// **'Haj {localpart} !'**
  String hajUser(String? localpart);

  /// No description provided for @syncInProgress.
  ///
  /// In en, this message translates to:
  /// **'Sync in progress'**
  String get syncInProgress;

  /// No description provided for @initialSync.
  ///
  /// In en, this message translates to:
  /// **'Initial sync in progress'**
  String get initialSync;

  /// No description provided for @syncOffline.
  ///
  /// In en, this message translates to:
  /// **'Sync interrupted'**
  String get syncOffline;

  /// No description provided for @syncFunctional.
  ///
  /// In en, this message translates to:
  /// **'Sync state healthy'**
  String get syncFunctional;

  /// No description provided for @lastSyncReceived.
  ///
  /// In en, this message translates to:
  /// **'Last sync : {timestamp} ({duration} ms)'**
  String lastSyncReceived(DateTime timestamp, Object duration);

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authenticationRequired;

  /// No description provided for @authenticateForAccount.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate with your credentials for {mxid}.'**
  String authenticateForAccount(Object mxid);

  /// No description provided for @passphraseNotEmpty.
  ///
  /// In en, this message translates to:
  /// **'The passphrase can\'t be empty'**
  String get passphraseNotEmpty;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @noMatch.
  ///
  /// In en, this message translates to:
  /// **'No match'**
  String get noMatch;

  /// No description provided for @keysMatch.
  ///
  /// In en, this message translates to:
  /// **'Keys match'**
  String get keysMatch;

  /// No description provided for @wipeAccount.
  ///
  /// In en, this message translates to:
  /// **'Wipe account'**
  String get wipeAccount;

  /// No description provided for @wipeAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'If you lost your device, you can wipe and reset your account. All messages and chats will be lost.'**
  String get wipeAccountWarning;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @connectPreviousDevice.
  ///
  /// In en, this message translates to:
  /// **'Connect previous device'**
  String get connectPreviousDevice;

  /// No description provided for @connectPreviousDeviceLong.
  ///
  /// In en, this message translates to:
  /// **'Please verify existing device.'**
  String get connectPreviousDeviceLong;

  /// No description provided for @deviceNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'I don\'t have my device available.'**
  String get deviceNotAvailable;

  /// No description provided for @compareSasNumbers.
  ///
  /// In en, this message translates to:
  /// **'Compare security numbers'**
  String get compareSasNumbers;

  /// No description provided for @compareSasExplanation.
  ///
  /// In en, this message translates to:
  /// **'Check if the numbers on your device are identical with the numbers on the other device requesting the verification.'**
  String get compareSasExplanation;

  /// No description provided for @incomingVerificationRequest.
  ///
  /// In en, this message translates to:
  /// **'Incoming verification request'**
  String get incomingVerificationRequest;

  /// No description provided for @waitingForVerification.
  ///
  /// In en, this message translates to:
  /// **'Waiting for verification'**
  String get waitingForVerification;

  /// No description provided for @waitingForVerificationFallback.
  ///
  /// In en, this message translates to:
  /// **'Please verify using your second device or enter your recovery phrase.'**
  String get waitingForVerificationFallback;

  /// No description provided for @incomingVerificationRequestUser.
  ///
  /// In en, this message translates to:
  /// **'{user} wants to verify'**
  String incomingVerificationRequestUser(String? user);

  /// No description provided for @incomingVerificationRequestMyself.
  ///
  /// In en, this message translates to:
  /// **'There is an incoming verification request to verify another device for your account.'**
  String get incomingVerificationRequestMyself;

  /// No description provided for @incomingVerificationRequestLong.
  ///
  /// In en, this message translates to:
  /// **'There is an incoming verification request, do you want to handle the verification request ?'**
  String get incomingVerificationRequestLong;

  /// No description provided for @reject.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'Proceed'**
  String get proceed;

  /// No description provided for @enterRecoveryPhrase.
  ///
  /// In en, this message translates to:
  /// **'Enter recovery phrase'**
  String get enterRecoveryPhrase;

  /// No description provided for @keyVerificationErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'There was an error verifying your device.'**
  String get keyVerificationErrorGeneric;

  /// No description provided for @keyVerificationErrorUser.
  ///
  /// In en, this message translates to:
  /// **'The verification was rejected.'**
  String get keyVerificationErrorUser;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @verificationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Key verification successful'**
  String get verificationSuccessful;

  /// No description provided for @verifyLogin.
  ///
  /// In en, this message translates to:
  /// **'Verify your new login'**
  String get verifyLogin;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// No description provided for @verifyWithOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Verify with other device'**
  String get verifyWithOtherDevice;

  /// No description provided for @verifyMethodsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'You don\'t have a verification method available ?'**
  String get verifyMethodsNotAvailable;

  /// No description provided for @resetAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'You will use all your past messages. This cannot be undone.'**
  String get resetAccountWarning;

  /// No description provided for @verifyWithPassphrase.
  ///
  /// In en, this message translates to:
  /// **'Verify with passphrase'**
  String get verifyWithPassphrase;

  /// No description provided for @passphraseNoWhitespace.
  ///
  /// In en, this message translates to:
  /// **'The passphrase cannot contain any whitespace characters !'**
  String get passphraseNoWhitespace;

  /// No description provided for @errorTryAgain.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorTryAgain;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'submit'**
  String get submit;

  /// No description provided for @togglePassword.
  ///
  /// In en, this message translates to:
  /// **'Toggle password visibility'**
  String get togglePassword;

  /// No description provided for @loggingInToClient.
  ///
  /// In en, this message translates to:
  /// **'Login to account'**
  String get loggingInToClient;

  /// No description provided for @pendingInvite.
  ///
  /// In en, this message translates to:
  /// **'Pending invite'**
  String get pendingInvite;

  /// No description provided for @invite.
  ///
  /// In en, this message translates to:
  /// **'Invite'**
  String get invite;

  /// Please keep the Guillemets as quotation marks in case this is in any way understandable (not necessarily lexically correct) in your language.
  ///
  /// In en, this message translates to:
  /// **'You are invited to join the room : « {roomname} ».'**
  String inviteLongRoom(String roomname);

  /// No description provided for @inviteLongDM.
  ///
  /// In en, this message translates to:
  /// **'You are invited to discuss with « {displayname} ».'**
  String inviteLongDM(Object displayname);

  /// No description provided for @roomParticipants.
  ///
  /// In en, this message translates to:
  /// **'{participants, plural, =0{No participants} =1{1 participant} other{{participants} participants}}'**
  String roomParticipants(int participants);

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join room'**
  String get joinRoom;

  /// No description provided for @knockRoom.
  ///
  /// In en, this message translates to:
  /// **'Knock to join'**
  String get knockRoom;

  /// No description provided for @youCannotJoinThisRoom.
  ///
  /// In en, this message translates to:
  /// **'You cannot join this room.'**
  String get youCannotJoinThisRoom;

  /// No description provided for @addAccount.
  ///
  /// In en, this message translates to:
  /// **'Add another account'**
  String get addAccount;

  /// No description provided for @regionAccountSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Screen region: Account switcher.'**
  String get regionAccountSwitcher;

  /// No description provided for @regionChatContents.
  ///
  /// In en, this message translates to:
  /// **'Screen region: Chat content.'**
  String get regionChatContents;

  /// No description provided for @loadingHomeservers.
  ///
  /// In en, this message translates to:
  /// **'Loading homeservers. Progress unknown. Please wait.'**
  String get loadingHomeservers;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @typeGroupImages.
  ///
  /// In en, this message translates to:
  /// **'Images'**
  String get typeGroupImages;

  /// No description provided for @typeGroupVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get typeGroupVideos;

  /// No description provided for @typeGroupAudio.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get typeGroupAudio;

  /// No description provided for @typeGroupFiles.
  ///
  /// In en, this message translates to:
  /// **'All files'**
  String get typeGroupFiles;

  /// No description provided for @msgTypeText.
  ///
  /// In en, this message translates to:
  /// **'Send a regular text message.'**
  String get msgTypeText;

  /// No description provided for @msgTypeEmote.
  ///
  /// In en, this message translates to:
  /// **'Describe your mood.'**
  String get msgTypeEmote;

  /// No description provided for @msgTypeNotice.
  ///
  /// In en, this message translates to:
  /// **'Send an informative message bots cannot reply to.'**
  String get msgTypeNotice;

  /// No description provided for @msgTypeImage.
  ///
  /// In en, this message translates to:
  /// **'Send an image file.'**
  String get msgTypeImage;

  /// No description provided for @msgTypeVideo.
  ///
  /// In en, this message translates to:
  /// **'Send a video file.'**
  String get msgTypeVideo;

  /// No description provided for @msgTypeAudio.
  ///
  /// In en, this message translates to:
  /// **'Send an audio file.'**
  String get msgTypeAudio;

  /// No description provided for @msgTypeFile.
  ///
  /// In en, this message translates to:
  /// **'Send a file.'**
  String get msgTypeFile;

  /// No description provided for @msgTypeLocation.
  ///
  /// In en, this message translates to:
  /// **'Share your location.'**
  String get msgTypeLocation;

  /// No description provided for @msgTypeSticker.
  ///
  /// In en, this message translates to:
  /// **'Send a sticker.'**
  String get msgTypeSticker;

  /// No description provided for @msgTypeBadEncrypted.
  ///
  /// In en, this message translates to:
  /// **'Annoy your peer with a message they cannot decrypt.'**
  String get msgTypeBadEncrypted;

  /// No description provided for @msgTypeNone.
  ///
  /// In en, this message translates to:
  /// **'Send no message.'**
  String get msgTypeNone;

  /// No description provided for @filesSelected.
  ///
  /// In en, this message translates to:
  /// **'{files, plural, =0{No files} =1{One file} other{{files} files}} selected. Sending files is not supported yet.}'**
  String filesSelected(int files);

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last month'**
  String get lastMonth;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @saveAs.
  ///
  /// In en, this message translates to:
  /// **'Save as'**
  String get saveAs;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @errorDownloadingAttachment.
  ///
  /// In en, this message translates to:
  /// **'Error downloading the message attachment.'**
  String get errorDownloadingAttachment;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'nb', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Future<AppLocalizations> lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return app_localizations_de
          .loadLibrary()
          .then((dynamic _) => app_localizations_de.AppLocalizationsDe());
    case 'en':
      return app_localizations_en
          .loadLibrary()
          .then((dynamic _) => app_localizations_en.AppLocalizationsEn());
    case 'nb':
      return app_localizations_nb
          .loadLibrary()
          .then((dynamic _) => app_localizations_nb.AppLocalizationsNb());
    case 'nl':
      return app_localizations_nl
          .loadLibrary()
          .then((dynamic _) => app_localizations_nl.AppLocalizationsNl());
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
