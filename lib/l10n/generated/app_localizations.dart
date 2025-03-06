import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart' deferred as app_localizations_de;
import 'app_localizations_en.dart' deferred as app_localizations_en;
import 'app_localizations_et.dart' deferred as app_localizations_et;
import 'app_localizations_nb.dart' deferred as app_localizations_nb;
import 'app_localizations_nl.dart' deferred as app_localizations_nl;
import 'app_localizations_ta.dart' deferred as app_localizations_ta;

// ignore_for_file: type=lint

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
    Locale('et'),
    Locale('nb'),
    Locale('nl'),
    Locale('ta')
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

  /// No description provided for @loginLegacySso.
  ///
  /// In en, this message translates to:
  /// **'Login using legacy SSO'**
  String get loginLegacySso;

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

  /// Describes the device in the list of devices. The parameter is a localized phrase like `web` or `Linux`.
  ///
  /// In en, this message translates to:
  /// **'< polycule > on {hostname} ({platform})'**
  String clientDisplayNameHostname(String hostname, String platform);

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
  String lastSyncReceived(DateTime timestamp, int duration);

  /// No description provided for @editedToday.
  ///
  /// In en, this message translates to:
  /// **'Edited: {timestamp}'**
  String editedToday(DateTime timestamp);

  /// No description provided for @editedAt.
  ///
  /// In en, this message translates to:
  /// **'Edited: {timestamp}'**
  String editedAt(String timestamp);

  /// No description provided for @authenticationRequired.
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get authenticationRequired;

  /// No description provided for @authenticateForAccount.
  ///
  /// In en, this message translates to:
  /// **'Please authenticate with your credentials for {mxid}.'**
  String authenticateForAccount(String mxid);

  /// No description provided for @replyUserSentDate.
  ///
  /// In en, this message translates to:
  /// **'{username} wrote {formattedDate} :'**
  String replyUserSentDate(String username, String formattedDate);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

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
  /// **'Compare SAS security numbers'**
  String get compareSasNumbers;

  /// No description provided for @compareSasEmojis.
  ///
  /// In en, this message translates to:
  /// **'Compare SAS security emojis'**
  String get compareSasEmojis;

  /// No description provided for @compareSasExplanation.
  ///
  /// In en, this message translates to:
  /// **'Check if the SAS on your device are identical with the SAS on the other device requesting the verification.'**
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
  /// **'The verification was canceled.'**
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
  /// **'Verify your key material'**
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

  /// No description provided for @sendingFiles.
  ///
  /// In en, this message translates to:
  /// **'{files, plural, =0{Sending no files.} =1{One file} other{{files} files}} sending ...}'**
  String sendingFiles(int files);

  /// No description provided for @noFilesSelected.
  ///
  /// In en, this message translates to:
  /// **'No files selected.'**
  String get noFilesSelected;

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

  /// No description provided for @searchPromptLabel.
  ///
  /// In en, this message translates to:
  /// **'Command, user, room name or MXID'**
  String get searchPromptLabel;

  /// No description provided for @appearanceAccessibilitySettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance and accessibility'**
  String get appearanceAccessibilitySettings;

  /// No description provided for @polyculeSettings.
  ///
  /// In en, this message translates to:
  /// **'Configure your < polycule >'**
  String get polyculeSettings;

  /// No description provided for @systemLanguage.
  ///
  /// In en, this message translates to:
  /// **'Device language'**
  String get systemLanguage;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark terminal'**
  String get dark;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light rose'**
  String get light;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System theme'**
  String get systemTheme;

  /// No description provided for @fontAccessibility.
  ///
  /// In en, this message translates to:
  /// **'Font accessibility'**
  String get fontAccessibility;

  /// No description provided for @inclusiveSans.
  ///
  /// In en, this message translates to:
  /// **'Increased readability font'**
  String get inclusiveSans;

  /// No description provided for @openDyslexic.
  ///
  /// In en, this message translates to:
  /// **'Dyslexia-assisting font'**
  String get openDyslexic;

  /// No description provided for @serif.
  ///
  /// In en, this message translates to:
  /// **'Serif font'**
  String get serif;

  /// No description provided for @defaultFont.
  ///
  /// In en, this message translates to:
  /// **'Default font'**
  String get defaultFont;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color settings'**
  String get color;

  /// No description provided for @systemColor.
  ///
  /// In en, this message translates to:
  /// **'System color'**
  String get systemColor;

  /// No description provided for @defaultColor.
  ///
  /// In en, this message translates to:
  /// **'Theme default color'**
  String get defaultColor;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @highContrast.
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// No description provided for @aboutPolycule.
  ///
  /// In en, this message translates to:
  /// **'About < polycule >'**
  String get aboutPolycule;

  /// A content notice warning about spoilers or sensitive contents of a message.
  /// Please keep the Guillemets as quotation marks in case this is in any way understandable (not necessarily lexically correct) in your language.
  ///
  /// In en, this message translates to:
  /// **'CN : « {notice} »'**
  String contentNotice(String notice);

  /// No description provided for @contentNoticeFallback.
  ///
  /// In en, this message translates to:
  /// **'Content notice'**
  String get contentNoticeFallback;

  /// No description provided for @webUriHandlerTitle.
  ///
  /// In en, this message translates to:
  /// **'< polycule > [matrix] client'**
  String get webUriHandlerTitle;

  /// No description provided for @jumpToMessage.
  ///
  /// In en, this message translates to:
  /// **'Jump to message {message}'**
  String jumpToMessage(String message);

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account to continue'**
  String get selectAccount;

  /// No description provided for @sharingFiles.
  ///
  /// In en, this message translates to:
  /// **'Sending {files, plural, =1{a file} other{{files} files}}.'**
  String sharingFiles(int files);

  /// No description provided for @sharingText.
  ///
  /// In en, this message translates to:
  /// **'Share text to room'**
  String get sharingText;

  /// No description provided for @sendFiles.
  ///
  /// In en, this message translates to:
  /// **'Send files'**
  String get sendFiles;

  /// No description provided for @checkingTotalSendSize.
  ///
  /// In en, this message translates to:
  /// **'Checking total send size ...'**
  String get checkingTotalSendSize;

  /// No description provided for @totalSendSize.
  ///
  /// In en, this message translates to:
  /// **'{size, plural, =0{Total send size : 0 bytes} =1{Total send size : 1 byte} other{Total send size : {size} bytes}}}'**
  String totalSendSize(int size);

  /// No description provided for @fileSize.
  ///
  /// In en, this message translates to:
  /// **'{size, plural, =0{File size : 0 bytes} =1{File size : 1 byte} other{File size : {size} bytes}}}'**
  String fileSize(int size);

  /// No description provided for @mimeType.
  ///
  /// In en, this message translates to:
  /// **'File type : {mimeType}'**
  String mimeType(String? mimeType);

  /// No description provided for @matrixRoomShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Join the room « {roomname} » on [matrix]'**
  String matrixRoomShareSubject(String roomname);

  /// No description provided for @matrixUserShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Contact « {mxid} » on [matrix]'**
  String matrixUserShareSubject(String mxid);

  /// No description provided for @fileDownloadedTo.
  ///
  /// In en, this message translates to:
  /// **'File saved as « {name} ».'**
  String fileDownloadedTo(String name);

  /// No description provided for @openFile.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openFile;

  /// No description provided for @compressFiles.
  ///
  /// In en, this message translates to:
  /// **'Compress files'**
  String get compressFiles;

  /// No description provided for @compressFilesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'For supported file types only'**
  String get compressFilesSubtitle;

  /// No description provided for @cancelSending.
  ///
  /// In en, this message translates to:
  /// **'Cancel sending'**
  String get cancelSending;

  /// No description provided for @retrySending.
  ///
  /// In en, this message translates to:
  /// **'Retry sending'**
  String get retrySending;

  /// No description provided for @accountSettings.
  ///
  /// In en, this message translates to:
  /// **'Account settings'**
  String get accountSettings;

  /// No description provided for @previewRoom.
  ///
  /// In en, this message translates to:
  /// **'Preview as guest'**
  String get previewRoom;

  /// No description provided for @joinMatrixCall.
  ///
  /// In en, this message translates to:
  /// **'Join [matrix] call'**
  String get joinMatrixCall;

  /// No description provided for @matrixCallTooltip.
  ///
  /// In en, this message translates to:
  /// **'Call ID : {roomId}'**
  String matrixCallTooltip(String roomId);

  /// No description provided for @pushSettings.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushSettings;

  /// No description provided for @unifiedPushUnavailable.
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush is not available on your device.'**
  String get unifiedPushUnavailable;

  /// No description provided for @selectPushDistributor.
  ///
  /// In en, this message translates to:
  /// **'Select your UnifiedPush distributor'**
  String get selectPushDistributor;

  /// No description provided for @disablePushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Disable push notifications'**
  String get disablePushNotifications;

  /// No description provided for @pushInformationPolycule.
  ///
  /// In en, this message translates to:
  /// **'Currently, < polycule > only supports push notifications on Android. Linux support is planned.'**
  String get pushInformationPolycule;

  /// No description provided for @unifiedPushAbout.
  ///
  /// In en, this message translates to:
  /// **'You need to install a distributor for push notifications to work.\nYou can find more information at : https://unifiedpush.org/users/intro/'**
  String get unifiedPushAbout;

  /// No description provided for @unifiedPushLink.
  ///
  /// In en, this message translates to:
  /// **'https://unifiedpush.org/users/intro/'**
  String get unifiedPushLink;

  /// No description provided for @setupUnifiedPush.
  ///
  /// In en, this message translates to:
  /// **'Setup UnifiedPush'**
  String get setupUnifiedPush;

  /// No description provided for @googleFirebase.
  ///
  /// In en, this message translates to:
  /// **'Google Firebase Cloud Messaging'**
  String get googleFirebase;

  /// No description provided for @newNotification.
  ///
  /// In en, this message translates to:
  /// **'New message in < polycyule >'**
  String get newNotification;

  /// No description provided for @pushChannelName.
  ///
  /// In en, this message translates to:
  /// **'Incoming messages'**
  String get pushChannelName;

  /// No description provided for @directChats.
  ///
  /// In en, this message translates to:
  /// **'Direct message rooms'**
  String get directChats;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Group rooms'**
  String get groups;

  /// No description provided for @unifiedPush.
  ///
  /// In en, this message translates to:
  /// **'UnifiedPush'**
  String get unifiedPush;

  /// No description provided for @reply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get reply;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @redact.
  ///
  /// In en, this message translates to:
  /// **'Redact'**
  String get redact;

  /// No description provided for @copyMessage.
  ///
  /// In en, this message translates to:
  /// **'Copy message'**
  String get copyMessage;

  /// No description provided for @confirmRedact.
  ///
  /// In en, this message translates to:
  /// **'Redact event'**
  String get confirmRedact;

  /// No description provided for @redactEventLong.
  ///
  /// In en, this message translates to:
  /// **'Do you permanently want to redact the event {eventId} ?'**
  String redactEventLong(String eventId);

  /// No description provided for @logoutCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Logout from this account.'**
  String get logoutCommandSyntax;

  /// No description provided for @roomnameCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Set the room name to [name].'**
  String get roomnameCommandSyntax;

  /// No description provided for @roomdescriptionCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Set the room description to [description].'**
  String get roomdescriptionCommandSyntax;

  /// No description provided for @sendCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send a text message. [m.text]'**
  String get sendCommandSyntax;

  /// No description provided for @meCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Describe your mood. [m.emote]'**
  String get meCommandSyntax;

  /// No description provided for @dmCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Create a DM room. [mxid] [--no-encryption?]'**
  String get dmCommandSyntax;

  /// No description provided for @createCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Create a room. [name?] [--no-encryption?]'**
  String get createCommandSyntax;

  /// No description provided for @plainCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send a text message without markdown parsing. [m.text]'**
  String get plainCommandSyntax;

  /// No description provided for @htmlCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send a text message in raw HTML. [m.text]'**
  String get htmlCommandSyntax;

  /// No description provided for @reactCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Reply with a reaction. [reaction]'**
  String get reactCommandSyntax;

  /// No description provided for @joinCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Join a room. [mxid]'**
  String get joinCommandSyntax;

  /// No description provided for @leaveCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Leave the present room.'**
  String get leaveCommandSyntax;

  /// No description provided for @opCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Set a member power level. [mxid] [50?]'**
  String get opCommandSyntax;

  /// No description provided for @kickCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Kick member. [mxid]'**
  String get kickCommandSyntax;

  /// No description provided for @banCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Ban member. [mxid]'**
  String get banCommandSyntax;

  /// No description provided for @unbanCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Unban member. [mxid]'**
  String get unbanCommandSyntax;

  /// No description provided for @inviteCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Invite member. [mxid]'**
  String get inviteCommandSyntax;

  /// No description provided for @myroomnickCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Set a custom nick in this room. [displayname]'**
  String get myroomnickCommandSyntax;

  /// No description provided for @myroomavatarCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Set a custom mxc avatar in this room. [mxc]'**
  String get myroomavatarCommandSyntax;

  /// No description provided for @discardsessionCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Discard your outbound room session.'**
  String get discardsessionCommandSyntax;

  /// No description provided for @clearcacheCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Clear the account\'s local cache.'**
  String get clearcacheCommandSyntax;

  /// No description provided for @markasdmCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Mark the current room as a DM with a member. [mxid]'**
  String get markasdmCommandSyntax;

  /// No description provided for @markasgroupCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Remove the current room from DM list.'**
  String get markasgroupCommandSyntax;

  /// No description provided for @hugCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send virtual hugs.'**
  String get hugCommandSyntax;

  /// No description provided for @googlyCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send virtual googly eyes.'**
  String get googlyCommandSyntax;

  /// No description provided for @cuddleCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send virtual cuddles.'**
  String get cuddleCommandSyntax;

  /// No description provided for @sendrawCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Send a raw event. [content]'**
  String get sendrawCommandSyntax;

  /// No description provided for @ignoreCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Ignore a user. [mxid]'**
  String get ignoreCommandSyntax;

  /// No description provided for @unignoreCommandSyntax.
  ///
  /// In en, this message translates to:
  /// **'Unignore a user. [mxid]'**
  String get unignoreCommandSyntax;

  /// No description provided for @noErrorReported.
  ///
  /// In en, this message translates to:
  /// **'No error reported.'**
  String get noErrorReported;

  /// No description provided for @commandInvalid.
  ///
  /// In en, this message translates to:
  /// **'This is no valid < polycule > command.'**
  String get commandInvalid;

  /// No description provided for @commandHelp.
  ///
  /// In en, this message translates to:
  /// **'Show help'**
  String get commandHelp;

  /// No description provided for @availableCommands.
  ///
  /// In en, this message translates to:
  /// **'Available commands'**
  String get availableCommands;

  /// No description provided for @commandError.
  ///
  /// In en, this message translates to:
  /// **'Exit code 1'**
  String get commandError;

  /// No description provided for @noStickerPacks.
  ///
  /// In en, this message translates to:
  /// **'Neither your account nor this room has any sticker pack available.'**
  String get noStickerPacks;

  /// No description provided for @react.
  ///
  /// In en, this message translates to:
  /// **'Send reaction'**
  String get react;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Application logs'**
  String get logs;

  /// No description provided for @reload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get reload;

  /// No description provided for @runtimeError.
  ///
  /// In en, this message translates to:
  /// **'Your < polycule > was buggy'**
  String get runtimeError;

  /// No description provided for @logSingleError.
  ///
  /// In en, this message translates to:
  /// **'Anonymously share'**
  String get logSingleError;

  /// No description provided for @enableSentry.
  ///
  /// In en, this message translates to:
  /// **'Always share'**
  String get enableSentry;

  /// No description provided for @errorReporting.
  ///
  /// In en, this message translates to:
  /// **'Error reporting'**
  String get errorReporting;

  /// No description provided for @errorReportingLong.
  ///
  /// In en, this message translates to:
  /// **'You can enable error reporting to help finding bugs in < polycule >.'**
  String get errorReportingLong;

  /// No description provided for @errorReportingPrivacy.
  ///
  /// In en, this message translates to:
  /// **'This will connect to GitLab.com, the source code host of < polycyle > and anonymously share occurring errors and their causes. This will not share any personal data to the developer.'**
  String get errorReportingPrivacy;

  /// No description provided for @learnMore.
  ///
  /// In en, this message translates to:
  /// **'Learn more'**
  String get learnMore;

  /// No description provided for @gitLabPrivacy.
  ///
  /// In en, this message translates to:
  /// **'https://gitlab.com/help/operations/error_tracking.md'**
  String get gitLabPrivacy;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get fontSize;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @fontScaleLabel.
  ///
  /// In en, this message translates to:
  /// **'{scale}'**
  String fontScaleLabel(double scale);

  /// No description provided for @openDirectChat.
  ///
  /// In en, this message translates to:
  /// **'Open direct chat'**
  String get openDirectChat;

  /// No description provided for @startDirectChat.
  ///
  /// In en, this message translates to:
  /// **'Start direct chat'**
  String get startDirectChat;

  /// No description provided for @ignoreUser.
  ///
  /// In en, this message translates to:
  /// **'Ignore'**
  String get ignoreUser;

  /// No description provided for @unignoreUser.
  ///
  /// In en, this message translates to:
  /// **'Unignore'**
  String get unignoreUser;

  /// No description provided for @ignoreToggleWaiting.
  ///
  /// In en, this message translates to:
  /// **'Processing ignore state. This will take a while.'**
  String get ignoreToggleWaiting;

  /// No description provided for @roomStateWtf.
  ///
  /// In en, this message translates to:
  /// **'This room\'s security is a mess. Better avoid.'**
  String get roomStateWtf;

  /// No description provided for @roomStatePublic.
  ///
  /// In en, this message translates to:
  /// **'This room is publicly visible for everyone'**
  String get roomStatePublic;

  /// No description provided for @roomStatePublicKnock.
  ///
  /// In en, this message translates to:
  /// **'This room is publicly visible for everyone but they must knock before joining.'**
  String get roomStatePublicKnock;

  /// No description provided for @roomStateOpen.
  ///
  /// In en, this message translates to:
  /// **'This room is open for everyone who knows its link.'**
  String get roomStateOpen;

  /// No description provided for @roomStateKnock.
  ///
  /// In en, this message translates to:
  /// **'Users must knock before joining this room.'**
  String get roomStateKnock;

  /// No description provided for @roomStateSpace.
  ///
  /// In en, this message translates to:
  /// **'This room is open for space members only.'**
  String get roomStateSpace;

  /// No description provided for @roomStateUnpublic.
  ///
  /// In en, this message translates to:
  /// **'This room is private but not encrypted.'**
  String get roomStateUnpublic;

  /// No description provided for @roomStateEncrypted.
  ///
  /// In en, this message translates to:
  /// **'This room is encrypted but some members are not verified.'**
  String get roomStateEncrypted;

  /// No description provided for @roomStateVerifiedEncrypted.
  ///
  /// In en, this message translates to:
  /// **'This room is encrypted and every session is cross-signed.'**
  String get roomStateVerifiedEncrypted;

  /// No description provided for @oidcAppName.
  ///
  /// In en, this message translates to:
  /// **'< polycule >'**
  String get oidcAppName;

  /// No description provided for @oidcContact.
  ///
  /// In en, this message translates to:
  /// **'info@braid.business'**
  String get oidcContact;

  /// No description provided for @oidcAppUrl.
  ///
  /// In en, this message translates to:
  /// **'https://polycule.im/web'**
  String get oidcAppUrl;

  /// No description provided for @oidcLogoUrl.
  ///
  /// In en, this message translates to:
  /// **'https://polycule.im/web/assets/assets/logo/logo-circle.png'**
  String get oidcLogoUrl;

  /// No description provided for @oidcTosUrl.
  ///
  /// In en, this message translates to:
  /// **'https://polycule.im/web/tos.html'**
  String get oidcTosUrl;

  /// No description provided for @oicPolicyUri.
  ///
  /// In en, this message translates to:
  /// **'https://polycule.im/web/policy.html'**
  String get oicPolicyUri;

  /// No description provided for @loginOidc.
  ///
  /// In en, this message translates to:
  /// **'Login using OpenID Connect'**
  String get loginOidc;

  /// No description provided for @oidcConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get oidcConfirm;

  /// No description provided for @manageSessions.
  ///
  /// In en, this message translates to:
  /// **'Manage sessions'**
  String get manageSessions;

  /// No description provided for @deactivateAccount.
  ///
  /// In en, this message translates to:
  /// **'Deactivate account'**
  String get deactivateAccount;

  /// No description provided for @networkSettings.
  ///
  /// In en, this message translates to:
  /// **'Network settings'**
  String get networkSettings;

  /// No description provided for @useSystemProxy.
  ///
  /// In en, this message translates to:
  /// **'Permit device proxy settings'**
  String get useSystemProxy;

  /// No description provided for @verifyCertificates.
  ///
  /// In en, this message translates to:
  /// **'Verify TLS certificates'**
  String get verifyCertificates;

  /// No description provided for @verifyTlsCertificatesAndroid.
  ///
  /// In en, this message translates to:
  /// **'For older Android versions, the rotated Let\'s Encrypt ISRG ROOT X1 certificate is already included.'**
  String get verifyTlsCertificatesAndroid;

  /// No description provided for @sendTlsSNI.
  ///
  /// In en, this message translates to:
  /// **'Send plain text Server Name Indication'**
  String get sendTlsSNI;

  /// No description provided for @minTlsVersion.
  ///
  /// In en, this message translates to:
  /// **'Minimum required TLS version by the homeserver'**
  String get minTlsVersion;

  /// No description provided for @tls12.
  ///
  /// In en, this message translates to:
  /// **'TLS 1.2'**
  String get tls12;

  /// No description provided for @tls13.
  ///
  /// In en, this message translates to:
  /// **'TLS 1.3'**
  String get tls13;

  /// No description provided for @favoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get favoriteAdd;

  /// No description provided for @favoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get favoriteRemove;

  /// No description provided for @markRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// No description provided for @markUnread.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markUnread;

  /// No description provided for @leaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get leaveRoom;

  /// No description provided for @leaveRoomLong.
  ///
  /// In en, this message translates to:
  /// **'Please confirm to permanently leave the room « {name} ».'**
  String leaveRoomLong(String name);

  /// No description provided for @userDetails.
  ///
  /// In en, this message translates to:
  /// **'View user profile'**
  String get userDetails;

  /// No description provided for @markMute.
  ///
  /// In en, this message translates to:
  /// **'Mute room'**
  String get markMute;

  /// No description provided for @markUnmute.
  ///
  /// In en, this message translates to:
  /// **'Unmute room'**
  String get markUnmute;

  /// No description provided for @copyRoomAddress.
  ///
  /// In en, this message translates to:
  /// **'Copy public room address'**
  String get copyRoomAddress;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @startVerification.
  ///
  /// In en, this message translates to:
  /// **'Start verification'**
  String get startVerification;

  /// No description provided for @keyVerificationRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Key verification request sent.'**
  String get keyVerificationRequestSent;

  /// No description provided for @noHomeserverConnection.
  ///
  /// In en, this message translates to:
  /// **'No connection to homeserver.'**
  String get noHomeserverConnection;

  /// No description provided for @emojiSettings.
  ///
  /// In en, this message translates to:
  /// **'Emoji settings'**
  String get emojiSettings;

  /// No description provided for @defaultEmojiTone.
  ///
  /// In en, this message translates to:
  /// **'Default emoji tone'**
  String get defaultEmojiTone;

  /// No description provided for @autoplayAnimations.
  ///
  /// In en, this message translates to:
  /// **'Automatically play animated images and stickers'**
  String get autoplayAnimations;

  /// No description provided for @yellowSkin.
  ///
  /// In en, this message translates to:
  /// **'Yellow skin'**
  String get yellowSkin;

  /// No description provided for @paleSkin.
  ///
  /// In en, this message translates to:
  /// **'Pale skin'**
  String get paleSkin;

  /// No description provided for @demiPaleSkin.
  ///
  /// In en, this message translates to:
  /// **'Demi pale skin'**
  String get demiPaleSkin;

  /// No description provided for @mediumSkin.
  ///
  /// In en, this message translates to:
  /// **'Medium skin'**
  String get mediumSkin;

  /// No description provided for @brownSkin.
  ///
  /// In en, this message translates to:
  /// **'Brown skin'**
  String get brownSkin;

  /// No description provided for @blackSkin.
  ///
  /// In en, this message translates to:
  /// **'Black skin'**
  String get blackSkin;

  /// No description provided for @roomDetails.
  ///
  /// In en, this message translates to:
  /// **'Room details'**
  String get roomDetails;

  /// No description provided for @errorSendingSticker.
  ///
  /// In en, this message translates to:
  /// **'Error sending custom sticker.'**
  String get errorSendingSticker;

  /// No description provided for @viewSourceCode.
  ///
  /// In en, this message translates to:
  /// **'View source code'**
  String get viewSourceCode;

  /// No description provided for @eventSourceCode.
  ///
  /// In en, this message translates to:
  /// **'Event source code'**
  String get eventSourceCode;

  /// No description provided for @eventSourceContent.
  ///
  /// In en, this message translates to:
  /// **'Event content'**
  String get eventSourceContent;

  /// No description provided for @eventSourceJson.
  ///
  /// In en, this message translates to:
  /// **'Full JSON'**
  String get eventSourceJson;

  /// No description provided for @eventSourceOriginal.
  ///
  /// In en, this message translates to:
  /// **'Original event'**
  String get eventSourceOriginal;

  /// No description provided for @eventSourceBodyRaw.
  ///
  /// In en, this message translates to:
  /// **'Event body (raw)'**
  String get eventSourceBodyRaw;

  /// No description provided for @eventSourceBodyHtml.
  ///
  /// In en, this message translates to:
  /// **'Event body (HTML)'**
  String get eventSourceBodyHtml;

  /// No description provided for @eventSourceUnsigned.
  ///
  /// In en, this message translates to:
  /// **'Unsigned content'**
  String get eventSourceUnsigned;

  /// No description provided for @eventRendered.
  ///
  /// In en, this message translates to:
  /// **'Rendered event'**
  String get eventRendered;

  /// No description provided for @eventQuoted.
  ///
  /// In en, this message translates to:
  /// **'Quoted event'**
  String get eventQuoted;

  /// No description provided for @eventPreview.
  ///
  /// In en, this message translates to:
  /// **'Event preview'**
  String get eventPreview;

  /// No description provided for @blurHash.
  ///
  /// In en, this message translates to:
  /// **'Blur hash'**
  String get blurHash;

  /// No description provided for @linuxOidcWorkaround.
  ///
  /// In en, this message translates to:
  /// **'In case your web browser won\'t prompt you to open < polycule > after logging in, please ensure you granted to handle OAuth2.0 redirects in < polycule > by launching the following command in a terminal emulator :'**
  String get linuxOidcWorkaround;

  /// No description provided for @linuxOidcWorkaroundSnippet.
  ///
  /// In en, this message translates to:
  /// **'gio mime x-scheme-handler/im.polycule business.braid.polycule.desktop'**
  String get linuxOidcWorkaroundSnippet;

  /// No description provided for @setupSSSSLoading.
  ///
  /// In en, this message translates to:
  /// **'Encryption setup running. This might take a while.'**
  String get setupSSSSLoading;

  /// No description provided for @sessionId.
  ///
  /// In en, this message translates to:
  /// **'Session ID'**
  String get sessionId;

  /// No description provided for @sessionIpAddress.
  ///
  /// In en, this message translates to:
  /// **'Last IP address'**
  String get sessionIpAddress;

  /// No description provided for @sessionLastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get sessionLastSeen;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verifyAgain.
  ///
  /// In en, this message translates to:
  /// **'Verify again'**
  String get verifyAgain;

  /// No description provided for @rename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get rename;

  /// No description provided for @renameDevice.
  ///
  /// In en, this message translates to:
  /// **'Rename device'**
  String get renameDevice;

  /// No description provided for @deviceName.
  ///
  /// In en, this message translates to:
  /// **'Device display name'**
  String get deviceName;

  /// No description provided for @renameDeviceHint.
  ///
  /// In en, this message translates to:
  /// **'Leave blank to remove display name'**
  String get renameDeviceHint;

  /// No description provided for @openInIDP.
  ///
  /// In en, this message translates to:
  /// **'Open in identity provider'**
  String get openInIDP;

  /// No description provided for @deviceNoEncryption.
  ///
  /// In en, this message translates to:
  /// **'Does not support encryption'**
  String get deviceNoEncryption;

  /// No description provided for @deviceVerified.
  ///
  /// In en, this message translates to:
  /// **'Keys verified'**
  String get deviceVerified;

  /// No description provided for @deviceUnverified.
  ///
  /// In en, this message translates to:
  /// **'Keys unverified'**
  String get deviceUnverified;

  /// No description provided for @deviceBlocked.
  ///
  /// In en, this message translates to:
  /// **'Device blocked'**
  String get deviceBlocked;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @logoutWarning.
  ///
  /// In en, this message translates to:
  /// **'Confirm logout'**
  String get logoutWarning;

  /// No description provided for @logoutWarningLong.
  ///
  /// In en, this message translates to:
  /// **'When you log out and neither have any other session nor your recovery phrase, you will lose access to all you [matrix] messages.'**
  String get logoutWarningLong;

  /// No description provided for @keyBackupAvailable.
  ///
  /// In en, this message translates to:
  /// **'SSSS backup'**
  String get keyBackupAvailable;

  /// No description provided for @keyBackupExplanation.
  ///
  /// In en, this message translates to:
  /// **'Use Secure Secret Storage and Sharing to securely backup message keys for all your devices.'**
  String get keyBackupExplanation;

  /// No description provided for @ssssRecoveryKey.
  ///
  /// In en, this message translates to:
  /// **'SSSS recovery key'**
  String get ssssRecoveryKey;

  /// No description provided for @ssssRecoveryKeyExplanation.
  ///
  /// In en, this message translates to:
  /// **'Carefully store your Secure Secret Storage and Sharing recovery key at a secure place. Without your recovery key, all past messages will be lost forever.'**
  String get ssssRecoveryKeyExplanation;

  /// No description provided for @confirmSSSSKeyStored.
  ///
  /// In en, this message translates to:
  /// **'Key stored'**
  String get confirmSSSSKeyStored;

  /// No description provided for @yourCurrentDevice.
  ///
  /// In en, this message translates to:
  /// **'Your current device'**
  String get yourCurrentDevice;

  /// No description provided for @moveClientTooltip.
  ///
  /// In en, this message translates to:
  /// **'Move here'**
  String get moveClientTooltip;

  /// No description provided for @displayName.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayName;

  /// No description provided for @yourDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Your display name'**
  String get yourDisplayName;

  /// No description provided for @displayNameHint.
  ///
  /// In en, this message translates to:
  /// **'This is shown on your public profile.'**
  String get displayNameHint;

  /// No description provided for @changeDisplayName.
  ///
  /// In en, this message translates to:
  /// **'Change display name'**
  String get changeDisplayName;

  /// No description provided for @scanQrCode.
  ///
  /// In en, this message translates to:
  /// **'Scan QR code'**
  String get scanQrCode;

  /// No description provided for @compareSas.
  ///
  /// In en, this message translates to:
  /// **'Compare SAS secret'**
  String get compareSas;

  /// No description provided for @confirmQrScanned.
  ///
  /// In en, this message translates to:
  /// **'QR code successfully scanned.'**
  String get confirmQrScanned;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @scanQrWithOtherDevice.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with your other device.'**
  String get scanQrWithOtherDevice;

  /// No description provided for @clientSwitcher.
  ///
  /// In en, this message translates to:
  /// **'Switch account'**
  String get clientSwitcher;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return lookupAppLocalizations(locale);
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'de',
        'en',
        'et',
        'nb',
        'nl',
        'ta'
      ].contains(locale.languageCode);

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
    case 'et':
      return app_localizations_et
          .loadLibrary()
          .then((dynamic _) => app_localizations_et.AppLocalizationsEt());
    case 'nb':
      return app_localizations_nb
          .loadLibrary()
          .then((dynamic _) => app_localizations_nb.AppLocalizationsNb());
    case 'nl':
      return app_localizations_nl
          .loadLibrary()
          .then((dynamic _) => app_localizations_nl.AppLocalizationsNl());
    case 'ta':
      return app_localizations_ta
          .loadLibrary()
          .then((dynamic _) => app_localizations_ta.AppLocalizationsTa());
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
