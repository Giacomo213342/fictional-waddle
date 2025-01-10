import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:oidc/oidc.dart';
import 'package:olm/olm.dart' as olm;

import '../../../../l10n/generated/app_localizations.dart';
import '../../../pages/account_selector/account_selector.dart';
import '../../../pages/application_settings/application_settings.dart';
import '../../../pages/fatal_error/fatal_error_page.dart';
import '../../../pages/homeserver/homeserver.dart';
import '../../../pages/room_list/room_list.dart';
import '../../../pages/splash_screen/splash_screen.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../utils/error_logger.dart';
import '../../../utils/matrix/database/polycule_database_builder.dart';
import '../../../utils/matrix/oidc_delegation_extension.dart';
import '../../../utils/matrix/polycule_command_extension.dart';
import '../../../utils/matrix/push_manager.dart';
import '../../../utils/matrix/uia_helper.dart';
import '../../../utils/oidc_successful_page_response.dart';
import '../../../utils/polycule_http_client/polycule_http_client.dart';
import '../../../utils/runtime_suffix.dart';
import '../../../utils/secure_storage.dart';
import '../../error_handler_dialog.dart';
import '../../intent_manager.dart';
import '../../settings_manager.dart';
import '../key_verification/key_verification_request_widget.dart';
import '../uia/uia_oidc_account_management_dialog.dart';
import '../uia/uia_oidc_dialog.dart';
import '../uia/uia_password_dialog.dart';
import 'client_manager_view.dart';

typedef GetClientCallback = Client Function();

class ClientManagerWidget extends StatefulWidget {
  const ClientManagerWidget({
    super.key,
    required this.child,
    this.activeClientIdentifier = 1,
  });

  factory ClientManagerWidget.routeBuilder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) =>
      ClientManagerWidget(
        activeClientIdentifier:
            ClientManager.extractClientIdentifierFromRoute(state),
        child: child,
      );

  final int? activeClientIdentifier;
  final Widget child;

  @override
  State<ClientManagerWidget> createState() => ClientManager();
}

class ClientManager extends State<ClientManagerWidget> with RouteAware {
  static const _clientNamesKey = 'client_names';

  static String _makeClientName(int identifier) =>
      'polycule_client_$identifier';

  static List<Client> activeClients = [];

  static final _initializer = Completer<bool>();

  static Client? getClientByIdentifier(int identifier) {
    return activeClients
        .where((client) => client.clientName.clientIdentifier == identifier)
        .singleOrNull;
  }

  static int? extractClientIdentifierFromRoute(GoRouterState state) {
    final parameter = state.pathParameters['client'];
    if (parameter == null) {
      return null;
    }
    final identifier = int.tryParse(parameter);

    return identifier;
  }

  static final _loginClients = <int>{};

  static Completer<void>? storageLock;

  bool _initializationStarted = false;

  static Future<void>? waiForInitialization = _initializer.future;

  final suffix = getRuntimeSuffix();

  @override
  void initState() {
    _listenErrorLogging();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadClients(),
    );
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initializePushPlugin(),
    );
    super.initState();
  }

  Future<bool> _loadClients() async {
    // first ensure we have an HTTP client
    _httpClient =
        await PolyculeHttpClientManager.httpClientCallbackStream.first;
    _httpClientListener = PolyculeHttpClientManager.httpClientCallbackStream
        .listen(_updateHttpClients);

    if (activeClients.isNotEmpty) {
      return true;
    }
    if (_initializationStarted) {
      return _initializer.future;
    }
    _initializationStarted = true;

    final future = storageLock?.future;
    if (future != null) {
      Logs().d(
        'Storage locked. Waiting with client initialization.',
      );
      await future;
    }
    Logs().d(
      'Acquiring storage lock for client initialization.',
    );
    storageLock = Completer<void>();

    String? json;
    try {
      json = await kPolyculeSecureStorage.read(key: _clientNamesKey + suffix);
    } on PlatformException catch (e, s) {
      await kPolyculeSecureStorage.delete(key: _clientNamesKey + suffix);
      ErrorLogger().captureStackTrace(e, s);
    }
    if (json != null) {
      final identifiers = (jsonDecode(json) as Iterable).whereType<int>();
      for (final identifier in identifiers) {
        // if the client is already running (usually client 1), skip building it
        if (!activeClients.any(
          (client) => client.clientName.clientIdentifier == identifier,
        )) {
          activeClients.add(_buildClient(identifier));
        }
      }
    }
    if (activeClients.isEmpty) {
      activeClients.add(_buildClient(1));
    }
    storageLock?.complete();
    storageLock = null;
    Logs().d(
      'Released storage lock after initialization. '
      '${activeClients.length} clients running.',
    );

    setState(() {
      _initializer.complete(true);
    });
    return true;
  }

  static final Map<int, OidcUserManager> _oidc = {};

  static final Map<int, StreamSubscription<OidcEvent>?> _oidcSubscription = {};
  static final Map<int, StreamSubscription<OidcUser?>?> _oidcUserSubscription =
      {};

  final Map<int, StreamSubscription<LoginState>?> _loginStateListener = {};

  final Map<int, StreamSubscription<UiaRequest>?> _uiaListener = {};

  final Map<int, StreamSubscription<KeyVerification>?>
      _sasVerificationListener = {};

  static final Map<int, PushManager> pushManagers = {};

  StreamSubscription<(Object?, StackTrace?)>? _errorListener;
  StreamSubscription<ClientCallback>? _httpClientListener;

  ClientCallback? _httpClient;

  Client _buildClient(int identifier) {
    final client = Client(
      _makeClientName(identifier),
      databaseBuilder: _databaseBuilder,
      verificationMethods: {
        KeyVerificationMethod.numbers,
        KeyVerificationMethod.reciprocate,
      },
      nativeImplementations: kIsWeb
          ? NativeImplementationsWebWorker(Uri.parse('web_worker.dart.js'))
          : NativeImplementationsIsolate(compute),
      supportedLoginTypes: {
        AuthenticationTypes.password,
        AuthenticationTypes.sso,
      },
      onSoftLogout: _handleSoftLogout,
      httpClient: _httpClient?.call(),
      importantStateEvents: {
        'im.ponies.room_emotes',
      },
      enableDehydratedDevices: true,
      receiptsPublicByDefault: false,
      requestHistoryOnLimitedTimeline: true,
      shareKeysWithUnverifiedDevices: false,
    );
    client.registerPolyculeCommands();
    _loginStateListener[identifier]?.cancel();
    _loginStateListener[identifier] = client.onLoginStateChanged.stream.listen(
      (loginState) => _handleLoginStateChange(client, loginState),
    );
    _uiaListener[identifier]?.cancel();
    _uiaListener[identifier] = client.onUiaRequest.stream.listen(
      (request) => _handleUiaRequest(client, request),
    );
    _sasVerificationListener[identifier]?.cancel();
    _sasVerificationListener[identifier] = client
        .onKeyVerificationRequest.stream
        .listen(_handleSasVerificationRequest);
    pushManagers[identifier] = PushManager(
      client,
      AppLocalizations.of(context),
    );

    _initClient(client);
    return client;
  }

  static void storeOidcManager(Client client, OidcUserManager oidc) {
    if (_oidc.containsKey(client.clientName.clientIdentifier)) {
      return;
    }
    _oidcSubscription[client.clientName.clientIdentifier] =
        oidc.events().listen(
              (event) => _handleOidcEvent(client, event),
            );

    _oidcUserSubscription[client.clientName.clientIdentifier] =
        oidc.userChanges().listen(
              (user) => _handleOidcUserEvent(client, user),
            );
    _oidc[client.clientName.clientIdentifier] = oidc;
  }

  static Future<OidcUserManager?> buildOidcManager(
    Client client,
    List<String> locales, {
    bool enforceNewDevice = false,
  }) async {
    try {
      final store = client.oidcStore;

      final deviceId = client.deviceID ??
          await client.oidcEnsureDeviceId(
            enforceNewDevice,
          );

      final settings = OidcUserManagerSettings(
        redirectUri: _makePlatformRedirectUrl('oauth2redirect'),
        postLogoutRedirectUri: _makePlatformRedirectUrl('endsessionredirect'),
        frontChannelLogoutUri:
            kIsWeb ? Uri.parse('https://polycule.im/web/redirect.html') : null,
        uiLocales: locales,
        supportOfflineAuth: true,
        scope: [
          ...OidcUserManagerSettings.defaultScopes,
          // 'urn:matrix:client:api:*',
          'urn:matrix:org.matrix.msc2967.client:api:*',
          // 'urn:matrix:client:device:*',
          'urn:matrix:org.matrix.msc2967.client:device:$deviceId',
        ],
        prompt: ['consent'],
        extraAuthenticationParameters: {
          if (kIsWeb) 'response_mode': 'fragment',
        },
        options: const OidcPlatformSpecificOptions(
          linux: OidcPlatformSpecificOptions_Native(
            successfulPageResponse: oidcSuccessfulPageResponse,
          ),
        ),
      );

      final clientCredentials = OidcClientAuthentication.none(
        clientId: await client.oidcEnsureDynamicClientId(
          await OidcDynamicRegistrationData.fromAppLocalizations(),
        ),
      );

      final discoveryDocument = await client.oidcProviderMetadata();

      OidcUserManager manager;

      // the refresh request sometimes fails to afterwards verify with 401
      // TODO: investigate this

      manager = OidcUserManager(
        discoveryDocument: discoveryDocument,
        clientCredentials: clientCredentials,
        store: store,
        settings: settings,
        httpClient: client.httpClient,
      );
      try {
        await manager.init();
      } on FormatException {
        try {
          await manager.dispose();
        } catch (_) {}
        manager = OidcUserManager(
          discoveryDocument: discoveryDocument,
          clientCredentials: clientCredentials,
          store: store,
          settings: settings,
          httpClient: client.httpClient,
        );
        await manager.init();
      }

      storeOidcManager(client, manager);
      return manager;
    } catch (e, s) {
      if (e is OidcException) {
        Logs().e('OIDC exception for client ${client.clientName}.', e, s);
        rethrow;
      } else {
        Logs().v('Client ${client.clientName} does not support OIDC.');
        return null;
      }
    }
  }

  Client _buildNewClient() {
    final identifiers = activeClients
        .map((e) => e.clientName.clientIdentifier)
        .toList()
      ..sort();
    final identifier = identifiers.isEmpty ? 1 : identifiers.last + 1;
    final client = _buildClient(identifier);
    activeClients.add(client);
    return client;
  }

  Client getActiveClient() {
    final matchingClients = activeClients.where(
      (client) =>
          client.clientName.clientIdentifier ==
          (widget.activeClientIdentifier ?? 1),
    );
    if (matchingClients.isNotEmpty) {
      return matchingClients.single;
    }

    return _buildNewClient();
  }

  void addLoginClient() {
    final client = _buildNewClient();
    final identifier = client.clientName.clientIdentifier;
    _loginClients.add(identifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goMultiClient('/client/$identifier${SplashPage.routeName}');
    });
  }

  void setActiveClient(Client client) {
    final identifier = client.clientName.clientIdentifier;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.goMultiClient('/client/$identifier${SplashPage.routeName}');
    });
  }

  @override
  Widget build(BuildContext context) =>
      IntentManagerWidget(child: ClientManagerView(this));

  @override
  void dispose() {
    for (final subscription in _loginStateListener.values) {
      subscription?.cancel();
    }
    for (final subscription in _uiaListener.values) {
      subscription?.cancel();
    }
    for (final subscription in _sasVerificationListener.values) {
      subscription?.cancel();
    }
    _errorListener?.cancel();
    _httpClientListener?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClientManagerWidget oldWidget) {
    if (oldWidget.activeClientIdentifier != widget.activeClientIdentifier) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _handleLoginStateChange(Client client, LoginState state) async {
    switch (state) {
      case LoginState.loggedIn:
        // under no case start the app if encryption not supported
        // This should prevent from CI accidentally forgetting to bundle OLM
        try {
          Logs().d(
            'Launching with OLM version ${olm.get_library_version().join('.')}',
          );
        } on ArgumentError catch (e) {
          context.goMultiClient(FatalErrorPage.routeName, extra: e);
          return;
        }
        if (client.clientName.clientIdentifier ==
                getActiveClient().clientName.clientIdentifier &&
            !GoRouterState.of(context).uri.path.startsWith(
                  AccountSelectorPage.routeName,
                )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goMultiClient(RoomListPage.routeName);
          });
        }

        _ensureClientInDb(client);

        break;

      case LoginState.softLoggedOut:
        final oidc = _oidc[client.clientName.clientIdentifier];
        if (oidc != null) {
          return;
        }
        continue loggedOut;

      loggedOut:
      case LoginState.loggedOut:
        if (client.clientName.clientIdentifier ==
                getActiveClient().clientName.clientIdentifier &&
            !GoRouterState.of(context).uri.path.startsWith(
                  AccountSelectorPage.routeName,
                )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goMultiClient(HomeserverPage.routeName);
          });
        }

        if (!_loginClients.contains(client.clientName.clientIdentifier)) {
          _removeFromClientList(client);
        }
        break;
    }
  }

  Future<void> _handleUiaRequest(Client client, UiaRequest request) async {
    final oidc = _oidc[client.clientName.clientIdentifier];
    final handler = UiaHelper(
      client: client,
      oidc: oidc,
      request: request,
      authenticationOidcCallback: (request, oidc) => UiaOidcDialog(
        request: request,
        client: client,
        oidc: oidc,
      ).show(context),
      authenticationOidcAccountManagementCallback: (request, oidc, action) =>
          UiaOidcAccountManagementDialog(
        request: request,
        client: client,
        oidc: oidc,
        action: action,
      ).show(context),
      authenticationPasswordCallback: (request) => UiaPasswordDialog(
        request: request,
        client: client,
      ).show(context),
    );
    await handler.respond();
  }

  Future<void> _handleSasVerificationRequest(KeyVerification request) async {
    Logs().d('Incoming key verification request');
    return KeyVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: getActiveClient(),
    );
  }

  Future<void> _removeFromClientList(Client client) async {
    // if it's the only client left, we need to keep it running
    if (activeClients.length <= 1) {
      return;
    }

    final future = storageLock?.future;
    if (future != null) {
      Logs().d(
        'Storage locked. Waiting with client deletion.',
      );
      await future;
    }
    Logs().d(
      'Acquiring storage lock for client deletion.',
    );
    storageLock = Completer<void>();

    final identifier = client.clientName.clientIdentifier;

    await client.database?.delete();

    await _oidc[client.clientName.clientIdentifier]?.forgetUser();
    await _oidc[client.clientName.clientIdentifier]?.dispose();
    await _oidcSubscription[client.clientName.clientIdentifier]?.cancel();
    await _oidcUserSubscription[client.clientName.clientIdentifier]?.cancel();

    await client.dispose();

    setState(() {
      activeClients.removeWhere(
        (element) => element.clientName.clientIdentifier == identifier,
      );
    });

    final clientIdentifiers =
        activeClients.map((e) => e.clientName.clientIdentifier);
    await kPolyculeSecureStorage.write(
      key: _clientNamesKey + suffix,
      value: jsonEncode(clientIdentifiers.toList()),
    );
    storageLock?.complete();
    storageLock = null;

    Logs().d(
      'Released storage lock for client deletion.',
    );

    if (widget.activeClientIdentifier == identifier) {
      final newIdentifier = activeClients.first.clientName.clientIdentifier;
      if (!mounted) {
        return;
      }
      if (!GoRouterState.of(context)
          .uri
          .path
          .startsWith(AccountSelectorPage.routeName)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context
              .goMultiClient('/client/$newIdentifier${SplashPage.routeName}');
        });
      }
    }
  }

  Future<void> _ensureClientInDb(Client client) async {
    final identifier = client.clientName.clientIdentifier;
    setState(() {
      _loginClients.remove(identifier);
    });

    final future = storageLock?.future;
    if (future != null) {
      Logs().d(
        'Storage locked. Waiting to store the new client.',
      );
      await future;
    }
    Logs().d(
      'Acquiring storage lock in order to store the new client.',
    );
    storageLock = Completer<void>();

    String? storedJson;
    try {
      storedJson =
          await kPolyculeSecureStorage.read(key: _clientNamesKey + suffix);
    } on PlatformException catch (e, s) {
      await kPolyculeSecureStorage.delete(key: _clientNamesKey + suffix);
      ErrorLogger().captureStackTrace(e, s);
    }

    Set<int> identifiers = {};

    if (storedJson is String) {
      identifiers.addAll((jsonDecode(storedJson) as Iterable).whereType<int>());
    }
    if (!identifiers.contains(identifier)) {
      identifiers.add(identifier);
    }
    await kPolyculeSecureStorage.write(
      key: _clientNamesKey + suffix,
      value: jsonEncode(identifiers.toList()),
    );
    storageLock?.complete();
    storageLock = null;

    Logs().d(
      'Released storage lock after storing the new client.',
    );
  }

  Future<void> closeLoginClient(Client client) async {
    _loginClients.remove(client.clientName.clientIdentifier);

    await _removeFromClientList(client);
  }

  void openSettings() {
    context.push(ApplicationSettingsPage.routeName);
  }

  Future<DatabaseApi> _databaseBuilder(Client client) =>
      polyculeDatabaseBuilder(
        client,
        AppLocalizations.of(context),
      );

  Future<void> _initializePushPlugin() async {
    final notificationsPlugin = FlutterLocalNotificationsPlugin();

    await notificationsPlugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings(
          '@drawable/ic_launcher_foreground',
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: AppLocalizations.of(context).view,
          defaultIcon: ThemeLinuxIcon('business.braid.polycule'),
        ),
      ),
    );
  }

  void _listenErrorLogging() {
    _errorListener = ErrorLogger().errorStream.listen(_showErrorDialog);
  }

  Future<void> _showErrorDialog((Object?, StackTrace?) event) async {
    if (!SettingsManager.of(context).initCompleter.isCompleted) {
      await SettingsManager.of(context).initCompleter.future;
    }
    if (!mounted) {
      return;
    }
    if (SettingsManager.of(context).sentryEnabled.value == true) {
      return;
    }
    await ErrorHandlerDialog(
      error: event.$1,
      stackTrace: event.$2,
    ).showDialog(context);
  }

  static void _handleOidcEvent(Client client, OidcEvent event) {
    Logs().d('OIDC event $event');
  }

  static void _handleOidcUserEvent(Client client, OidcUser? user) {
    client.accessToken = user?.token.accessToken;

    Logs().d('OIDC user update for ${user?.userInfo}');
  }

  static Uri _makePlatformRedirectUrl(String method) => Uri.parse(
        kIsWeb
            ? 'https://polycule.im/web/redirect.html'
            : Platform.isAndroid || Platform.isIOS || Platform.isMacOS
                ? 'im.polycule:/$method'
                : Platform.isWindows || Platform.isLinux
                    // using port 0 means that we don't care which port is used,
                    // and a random unused port will be assigned.
                    //
                    // this is safer than passing a port yourself.
                    ? 'http://localhost:0/$method'
                    : 'http://localhost:0/$method',
      );

  Future<void> _initClient(Client client) async {
    final locale = AppLocalizations.of(context).localeName;

    DatabaseApi? database;
    final databaseBuilder = client.databaseBuilder;
    if (databaseBuilder != null) {
      database ??= await databaseBuilder(client);
    }

    final account = await database?.getClient(client.clientName);

    if (account != null) {
      final homeserver = Uri.parse(account['homeserver_url']);

      client.baseUri = homeserver;

      final oidc = await buildOidcManager(
        client,
        [locale],
      );
      if (oidc != null) {
        OidcUser? user;
        try {
          user = await oidc.refreshToken();
        } on OidcException catch (e) {
          // our refresh token expired or got lost - give the user a chance to
          // still reuse the session without wiping all data
          if (e.errorResponse?.error == 'invalid_grant') {
            user = await oidc.loginAuthorizationCodeFlow();
          } else {
            rethrow;
          }
        }

        final token = user?.token;
        final accessToken = token?.accessToken;
        if (user != null && token != null && accessToken != null) {
          storeOidcManager(client, oidc);

          /// as of now, we do not let the SDK handle our token refresh

          /*DateTime? expiresAt;

          final expiresIn = token.expiresIn;
          if (expiresIn != null) {
            expiresAt = DateTime.now().add(expiresIn);
          }*/

          // workaround missing user ID in token
          client.bearerToken = accessToken;
          final tokenInfo = await client.getTokenOwner();
          client.bearerToken = null;

          database?.updateClient(
            homeserver.toString(),
            accessToken,

            /// as of now, we do not let the SDK handle our token refresh
            // expiresAt,
            // token.refreshToken,
            null,
            null,
            tokenInfo.userId,
            tokenInfo.deviceId ?? account['device_id'],
            account['device_name'],
            account['prev_batch'],
            account['olm_account'],
          );
          await database?.close();
        }
      }
    }
    await client.init(
      waitForFirstSync: false,
    );
  }

  Future<void> _updateHttpClients(ClientCallback httpClientCallback) async {
    _httpClient = httpClientCallback;
    final locales = [AppLocalizations.of(context).localeName];
    for (final client in activeClients) {
      client.httpClient.close();
      client.httpClient = httpClientCallback.call();
      // ensure to also apply the new HTTP client to any OidcUserManager
      // therefore just rebuild the OIDC client
      final oidc = _oidc[client.clientName.clientIdentifier];
      if (oidc != null) {
        await oidc.dispose();
        await buildOidcManager(client, locales);
      }
    }
  }

  Future<void> _handleSoftLogout(Client client) async {
    // TODO: support Client._accessTokenExpiresAt

    final oidc = _oidc[client.clientName.clientIdentifier];
    if (oidc == null) {
      return client.refreshAccessToken();
    }
    try {
      OidcUser? user;
      try {
        user = await oidc.refreshToken();
      } on OidcException catch (e) {
        // our refresh token expired or got lost - give the user a chance to
        // still reuse the session without wiping all data
        if (e.errorResponse?.error == 'invalid_grant') {
          user = await oidc.loginAuthorizationCodeFlow();
        } else {
          rethrow;
        }
      }
      if (user == null) {
        // SDK will trigger hard logout
        return;
      }
      client.accessToken = user.token.accessToken;
      await client.login(
        LoginType.mLoginToken,
        deviceId: client.deviceID,
        token: user.token.accessToken,
      );
    } catch (e, s) {
      Logs().e('Error refreshing session', e, s);
      // SDK will trigger hard logout
      return;
    }
  }
}

extension ClientIdentifier on String {
  int get clientIdentifier {
    final regex = RegExp(r'^\w+(\d+)$');
    final matches = regex.firstMatch(this);
    return int.parse(matches!.group(1)!);
  }
}
