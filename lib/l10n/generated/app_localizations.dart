import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart' deferred as app_localizations_en;

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
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

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
  /// **'A simple and beautiful matrix client written in Flutter.'**
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
  /// **'Error connecting to server {homeserver}. Please check your selection.'**
  String errorConnectingToHomeserver(String homeserver);

  /// No description provided for @connectingToHomeserver.
  ///
  /// In en, this message translates to:
  /// **'Connecting to {homeserver} ...'**
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
  /// **'Your email should at least contain the @ symbol, a local part and your domain.'**
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
  /// **'Error during login, please check your credentials.'**
  String get loginError;

  /// No description provided for @loginErrorMessage.
  ///
  /// In en, this message translates to:
  /// **'Error during login : {message}'**
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
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

Future<AppLocalizations> lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return app_localizations_en
          .loadLibrary()
          .then((dynamic _) => app_localizations_en.AppLocalizationsEn());
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
