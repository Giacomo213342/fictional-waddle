import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' hide Client;
import 'package:matrix/matrix.dart';
import 'package:oidc/oidc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../secure_storage.dart';
import 'matrix_oidc_store.dart';

/// MSC 3824
extension LoginFlowOidcDelegationExtention on LoginFlow {
  bool get delegatedOidcCompatibility =>
      // delegated_oidc_compatibility
      additionalProperties['org.matrix.msc3824.delegated_oidc_compatibility'] ==
      true;
}

/// MSC 2965
extension WellKnownAuthenticationExtension on DiscoveryInformation {
  DiscoveryInformationAuthenticationData? get authentication =>
      DiscoveryInformationAuthenticationData.fromJson(
        // m.authentication
        additionalProperties['org.matrix.msc2965.authentication'],
      );
}

/// MSC 2964
class DiscoveryInformationAuthenticationData {
  const DiscoveryInformationAuthenticationData({this.issuer, this.account});

  final Uri? issuer;
  final Uri? account;

  static DiscoveryInformationAuthenticationData? fromJson(Object? json) {
    if (json is! Map) {
      return null;
    }
    final issuer = json['issuer'] as String?;
    final account = json['account'] as String?;
    return DiscoveryInformationAuthenticationData(
      issuer: issuer == null ? null : Uri.tryParse(issuer),
      account: account == null ? null : Uri.tryParse(account),
    );
  }
}

extension OidcAuthIssuerExtension on Client {
  /// MSC 4191
  Future<void> oidcAccountManagement({
    OidcAccountManagementActions? action,
    String? idTokenHint,
    String? deviceId,
  }) async {
    final providerMetadata = await oidcProviderMetadata();

    final rawUri = providerMetadata.src['account_management_uri'];
    if (rawUri == null) {
      return;
    }

    final uri = Uri.tryParse(rawUri)?.resolveUri(
      Uri(
        queryParameters: {
          if (action is OidcAccountManagementActions) 'action': action.action,
          if (deviceId is String) 'device_id': deviceId,
          if (idTokenHint is String) 'id_token_hint': idTokenHint,
        },
      ),
    );
    if (uri == null) {
      return;
    }
    await launchUrl(uri);
  }

  /// MSC 2964 & MSC 2967
  Future<String> oidcEnsureDeviceId([bool enforceNewDevice = false]) async {
    if (!enforceNewDevice) {
      final storedDeviceId = await oidcStore.get(
        OidcStoreNamespace.state,
        key: 'device_id',
      );
      if (storedDeviceId is String) {
        Logs().d('Restoring device ID $storedDeviceId.');
        return storedDeviceId;
      }
    }

    // MSC 1597

    // [A-Z] but without I and O (smth too similar to 1 and 0)
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    final deviceId = String.fromCharCodes(
      List.generate(
        10,
        (_) => chars.codeUnitAt(Random().nextInt(chars.length)),
      ),
    );
    await oidcStore.set(
      OidcStoreNamespace.state,
      key: 'device_id',
      value: deviceId,
    );
    Logs().d('Generated device ID $deviceId.');
    return deviceId;
  }

  /// MSC 2965
  Future<Uri> oidcAuthIssuer() async {
    /// _matrix/client/v1/auth_issuer
    final requestUri =
        Uri(path: '/_matrix/client/unstable/org.matrix.msc2965/auth_issuer');
    final request = Request('GET', baseUri!.resolveUri(requestUri));
    request.headers['content-type'] = 'application/json';
    final response = await httpClient.send(request);
    final responseBody = await response.stream.toBytes();
    if (response.statusCode != 200) {
      unexpectedResponse(response, responseBody);
    }
    final responseString = utf8.decode(responseBody);
    final json = jsonDecode(responseString);
    return Uri.parse(json['issuer'] as String);
  }

  MatrixOidcStore get oidcStore => MatrixOidcStore(
        client: this,
        secureStorageInstance: kPolyculeSecureStorage,
      );

  Future<String> oidcEnsureDynamicClientId(
    OidcDynamicRegistrationData registrationData,
  ) async {
    final storedClientId = await oidcStore.get(
      OidcStoreNamespace.state,
      key: 'client_id_${registrationData.url.authority}',
    );

    if (storedClientId is String) {
      Logs().d('Reusing Dynamic Client ID $storedClientId.');
      return storedClientId;
    }

    final providerMetadata = await oidcProviderMetadata();

    final clientId = await registerOAuth2Client(
      providerMetadata: providerMetadata,
      registrationData: registrationData,
    );
    await oidcStore.set(
      OidcStoreNamespace.state,
      key: 'client_id_${registrationData.url.authority}',
      value: clientId,
    );
    Logs().d('Registered Dynamic Client ID $clientId.');
    return clientId;
  }

  /// MSC 2966
  Future<String> registerOAuth2Client({
    required OidcProviderMetadata providerMetadata,
    required OidcDynamicRegistrationData registrationData,
  }) async {
    final request = Request('POST', providerMetadata.registrationEndpoint!);
    request.headers['content-type'] = 'application/json';
    request.bodyBytes = utf8.encode(jsonEncode(registrationData));
    final response = await httpClient.send(request);
    final responseBody = await response.stream.toBytes();
    if (response.statusCode >= 400) {
      unexpectedResponse(response, responseBody);
    }
    final responseString = utf8.decode(responseBody);
    final json = jsonDecode(responseString);
    return json['client_id'] as String;
  }

  Future<OidcProviderMetadata> oidcProviderMetadata() async {
    final store = oidcStore;
    await wellKnownLoading;

    // if present, use the issuer from .well-known, otherwise request separately
    final issuer = wellKnown?.authentication?.issuer ?? await oidcAuthIssuer();

    final uri =
        OidcUtils.getOpenIdConfigWellKnownUri(issuer.stripTrailingSlash());

    final key = uri.toString();
    final cachedDocument = await store.get(
      OidcStoreNamespace.discoveryDocument,
      key: key,
    );
    if (cachedDocument != null) {
      try {
        ///try loading the document
        return OidcProviderMetadata.fromJson(
          jsonDecode(cachedDocument) as Map<String, dynamic>,
        );
      } catch (e, st) {
        //swallow error.
        //remove the cached document.
        Logs().w(
          'Found a cached discovery document at key: $key, '
          "but couldn't parse it.\n"
          'Removing the bad key now.\n'
          'cached document: $cachedDocument',
          e,
          st,
        );
        await store
            .remove(OidcStoreNamespace.discoveryDocument, key: key)
            .onError((error, stackTrace) => null);
      }
    }

    OidcProviderMetadata? discoveryDocument;

    try {
      discoveryDocument = await OidcEndpoints.getProviderMetadata(
        uri,
        client: httpClient,
      );
    } catch (e, st) {
      //maybe there is no internet.
      if (discoveryDocument == null) {
        Logs().e(
          "Couldn't fetch the discoveryDocument",
          e,
          st,
        );
        rethrow;
      }
    }

    await store.set(
      OidcStoreNamespace.discoveryDocument,
      key: key,
      value: jsonEncode(discoveryDocument.src),
    );
    return discoveryDocument;
  }
}

class OidcDynamicRegistrationData {
  const OidcDynamicRegistrationData({
    required this.clientName,
    required this.contacts,
    required this.url,
    required this.logo,
    required this.tos,
    required this.policy,
    required this.redirect,
    this.responseTypes = const {
      OidcConstants_AuthorizationEndpoint_ResponseType.code,
    },
    this.grantTypes = const {
      OidcConstants_GrantType.authorizationCode,
      OidcConstants_GrantType.refreshToken,
    },
    required this.applicationType,
  });

  static Future<OidcDynamicRegistrationData> fromAppLocalizations() async {
    // we use English as fallback locale
    final defaultLocale =
        await AppLocalizations.delegate.load(const Locale('en'));

    final localizations = Map.fromEntries(
      await Future.wait(
        AppLocalizations.supportedLocales.map(
          (locale) => AppLocalizations.delegate
              .load(locale)
              .then((localizations) => MapEntry(locale, localizations)),
        ),
      ),
    );

    return OidcDynamicRegistrationData(
      clientName: {
        null: defaultLocale.oidcAppName,
        ...localizations.map(
          (locale, localizations) =>
              MapEntry(locale, localizations.oidcAppName),
        ),
      },
      contacts: {defaultLocale.oidcContact},
      url: Uri.parse(defaultLocale.oidcAppUrl),
      logo: {
        null: Uri.parse(defaultLocale.oidcLogoUrl),
        ...localizations.map(
          (locale, localizations) =>
              MapEntry(locale, Uri.parse(localizations.oidcLogoUrl)),
        ),
      },
      tos: {
        null: Uri.parse(defaultLocale.oidcTosUrl),
        ...localizations.map(
          (locale, localizations) =>
              MapEntry(locale, Uri.parse(localizations.oidcTosUrl)),
        ),
      },
      policy: {
        null: Uri.parse(defaultLocale.oicPolicyUri),
        ...localizations.map(
          (locale, localizations) =>
              MapEntry(locale, Uri.parse(localizations.oicPolicyUri)),
        ),
      },
      redirect: kIsWeb
          ? {Uri.parse('https://polycule.im/web/redirect.html')}
          : {
              if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)
                // not my fault *grumble*
                // https://github.com/element-hq/matrix-authentication-service/blob/main/crates/handlers/src/oauth2/registration.rs#L179
                Uri.parse('im.polycule:/oauth2redirect')
              else
                Uri.parse('http://localhost/oauth2redirect'),
            },
      applicationType: kIsWeb ? 'web' : 'native',
    );
  }

  final Map<Locale?, String> clientName;
  final Uri url;
  final Map<Locale?, Uri> logo;
  final Map<Locale?, Uri> tos;
  final Map<Locale?, Uri> policy;
  final Set<String> contacts;
  final Set<Uri> redirect;
  final Set<String> responseTypes;
  final Set<String> grantTypes;
  final String applicationType;

  String _localizedKey(String key, Locale? locale) => locale == null
      ? key
      : locale.countryCode == null
          ? '$key#${locale.languageCode.toLowerCase()}'
          : key +
              r'#' +
              locale.languageCode.toLowerCase() +
              r'-' +
              locale.countryCode!.toUpperCase();

  Map<String, Object?> toJson() => {
        ...clientName.map<String, String>(
          (locale, value) =>
              MapEntry(_localizedKey('client_name', locale), value),
        ),
        'client_uri': url.toString(),
        'contacts': contacts.toList(),
        ...logo.map<String, String>(
          (locale, value) =>
              MapEntry(_localizedKey('logo_uri', locale), value.toString()),
        ),
        ...tos.map<String, String>(
          (locale, value) =>
              MapEntry(_localizedKey('tos_uri', locale), value.toString()),
        ),
        ...policy.map<String, String>(
          (locale, value) =>
              MapEntry(_localizedKey('policy_uri', locale), value.toString()),
        ),
        // https://github.com/element-hq/matrix-authentication-service/issues/3638#issuecomment-2527352709
        'token_endpoint_auth_method': 'none',
        'redirect_uris': redirect.map<String>((uri) => uri.toString()).toList(),
        'response_types': responseTypes.toList(),
        'grant_types': grantTypes.toList(),
        'application_type': applicationType,
      };
}

/// MSC 4191
enum OidcAccountManagementActions {
  profile('profile'),
  sessionsList('sessions_list'),
  sessionView('session_view'),
  sessionEnd('session_end'),
  accountDeactivate('account_deactivate'),
  crossSigningReset('cross_signing_reset');

  const OidcAccountManagementActions(this.name);

  /// name as it appears in the metadata
  final String name;

  /// action as it is used for deep linking
  String get action => 'org.matrix.$name';
}
