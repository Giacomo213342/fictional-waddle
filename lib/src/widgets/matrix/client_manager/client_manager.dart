import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' hide Client;
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:mime/mime.dart';
import 'package:olm/olm.dart' as olm;

import '../../../../l10n/generated/app_localizations.dart';
import '../../../pages/account_selector/account_selector.dart';
import '../../../pages/account_settings/account_settings.dart';
import '../../../pages/application_settings/application_settings.dart';
import '../../../pages/fatal_error/fatal_error_page.dart';
import '../../../pages/homeserver/homeserver.dart';
import '../../../pages/room_list/room_list.dart';
import '../../../pages/splash_screen/splash_screen.dart';
import '../../../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../utils/error_logger.dart';
import '../../../utils/matrix/database/polycule_database_builder.dart';
import '../../../utils/matrix/matrix_refresh_token_client.dart';
import '../../../utils/matrix/polycule_command_extension.dart';
import '../../../utils/matrix/push_manager.dart';
import '../../../utils/matrix/uia_helper.dart';
import '../../../utils/polycule_http_client/polycule_http_client.dart';
import '../../../utils/runtime_suffix.dart';
import '../../../utils/secure_storage.dart';
import '../../error_dialog_scope.dart';
import '../../intent_manager.dart';
import '../key_verification/key_verification_request_widget.dart';
import '../uia/uia_oidc_account_management_dialog.dart';
import '../uia/uia_password_dialog.dart';
import 'client_manager_view.dart';

typedef GetClientCallback = Client Function();

class ClientManagerWidget extends StatefulWidget {
  const ClientManagerWidget({
    super.key,
    required this.child,
    this.activeClientIdentifier,
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

  static Future<void> waiForInitialization = _initializer.future;

  final suffix = getRuntimeSuffix();

  String? olmVersion;

  @override
  void initState() {
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

  final Map<int, StreamSubscription<LoginState>?> _loginStateListener = {};

  final Map<int, StreamSubscription<UiaRequest>?> _uiaListener = {};

  final Map<int, StreamSubscription<KeyVerification>?>
      _sasVerificationListener = {};

  static final Map<int, PushManager> pushManagers = {};

  StreamSubscription<ClientCallback>? _httpClientListener;

  ClientCallback? _httpClient;

  final nativeImplementations = kIsWeb
      ? NativeImplementationsWebWorker(Uri.parse('web_worker.dart.js'))
      : NativeImplementationsIsolate(compute);

  Client _buildClient(int identifier) {
    final httpClient = _httpClient!.call();
    final client = Client(
      _makeClientName(identifier),
      databaseBuilder: _databaseBuilder,
      verificationMethods: {
        KeyVerificationMethod.numbers,
        KeyVerificationMethod.reciprocate,
      },
      nativeImplementations: nativeImplementations,
      supportedLoginTypes: {
        AuthenticationTypes.password,
        AuthenticationTypes.sso,
      },
      onSoftLogout: _handleSoftLogout,
      httpClient: httpClient,
      importantStateEvents: {
        'im.ponies.room_emotes',
      },
      enableDehydratedDevices: true,
      receiptsPublicByDefault: false,
      requestHistoryOnLimitedTimeline: true,
      customImageResizer: _customImageResizer,
    );

    client.httpClient = _buildRetryClient(client, httpClient);

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
        .listen((request) => _handleSasVerificationRequest(client, request));
    pushManagers[identifier] = PushManager(
      client,
      AppLocalizations.of(context),
    );

    client.init(
      waitForFirstSync: false,
    );
    return client;
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

  Client? getActiveClient() {
    final matchingClients = activeClients.where(
      (client) =>
          client.clientName.clientIdentifier == widget.activeClientIdentifier,
    );
    if (matchingClients.isNotEmpty) {
      return matchingClients.single;
    }

    return null;
  }

  void addLoginClient() {
    final client = _buildNewClient();
    final identifier = client.clientName.clientIdentifier;
    _loginClients.add(identifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushMultiClient('/client/$identifier${SplashPage.routeName}');
    });
  }

  void setActiveClient(Client client) {
    final identifier = client.clientName.clientIdentifier;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.pushMultiClient('/client/$identifier${SplashPage.routeName}');
    });
  }

  @override
  Widget build(BuildContext context) => ErrorDialogScope(
        child: IntentManagerWidget(
          child: ClientManagerView(this),
        ),
      );

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
      case LoginState.softLoggedOut:
      // we let the SDK handle soft log out
      case LoginState.loggedIn:
        // under no case start the app if encryption not supported
        // This should prevent from CI accidentally forgetting to bundle OLM
        if (olmVersion == null) {
          try {
            olmVersion = olm.get_library_version().join('.');
            Logs().d('Running with OLM version $olmVersion');
          } on ArgumentError catch (e) {
            context.goMultiClient(FatalErrorPage.routeName, extra: e);
            return;
          }
        }

        final path = GoRouterState.of(context).uri.path;
        final isActiveClient =
            path.startsWith('/client/${client.clientName.clientIdentifier}') ||
                path == '/';
        final isAccountSelector = path.startsWith(
          AccountSelectorPage.routeName,
        );
        // TODO: remove awful match
        final isLoggedInRoute = path.startsWith(
          RegExp('/client/${client.clientName.clientIdentifier}'
              '(${RoomListPage.routeName}|${SsssBootstrapPage.routeName}|'
              '/user|${AccountSettings.routeName})'),
        );
        if (isActiveClient && !isAccountSelector && !isLoggedInRoute) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goMultiClient(RoomListPage.routeName);
          });
        }

        if (_loginClients.contains(client.clientName.clientIdentifier)) {
          _ensureClientInDb(client);
        }

        break;
      case LoginState.loggedOut:
        final path = GoRouterState.of(context).uri.path;
        if (path.startsWith('/client/${client.clientName.clientIdentifier}') &&
            !path.startsWith(
              AccountSelectorPage.routeName,
            )) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goMultiClient(HomeserverPage.routeName);
          });
        }

        if (!_loginClients.contains(client.clientName.clientIdentifier)) {
          await _removeFromClientList(client);
        }
        break;
    }
  }

  Future<void> _handleUiaRequest(Client client, UiaRequest request) async {
    final handler = UiaHelper(
      client: client,
      request: request,
      authenticationOidcAccountManagementCallback: (request, action) =>
          UiaOidcAccountManagementDialog(
        request: request,
        client: client,
        action: action,
      ).show(context),
      authenticationPasswordCallback: (request) => UiaPasswordDialog(
        request: request,
        client: client,
      ).show(context),
    );
    await handler.respond();
  }

  Future<void> _handleSasVerificationRequest(
    Client client,
    KeyVerification request,
  ) async {
    Logs().d('Incoming key verification request');
    return KeyVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: client,
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
        iOS: const DarwinInitializationSettings(),
        macOS: const DarwinInitializationSettings(),
      ),
    );
  }

  Future<void> _updateHttpClients(ClientCallback httpClientCallback) async {
    _httpClient = httpClientCallback;
    for (final client in activeClients) {
      client.httpClient.close();
      client.httpClient = _buildRetryClient(client, httpClientCallback.call());
    }
  }

  Future<void> _handleSoftLogout(Client client) async {
    while (true) {
      try {
        await client.refreshAccessToken();
        return;
      } on ClientException catch (e, s) {
        // keep waiting on network errors. This is likely due to
        // power savings on mobile.
        Logs().w('Error refreshing token. Retrying in 10 seconds.', e, s);
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }

  Future<MatrixImageFileResizedResponse?> _customImageResizer(
    MatrixImageFileResizeArguments args,
  ) =>
      Future.value(
        switch (lookupMimeType(args.fileName, headerBytes: args.bytes)) {
          null || 'image/svg+xml' => null,
          _ => nativeImplementations.shrinkImage(args, retryInDummy: true),
        },
      ).catchError((e, s) {
        Logs().w('Error shrinking image ${args.fileName}.', e, s);
        return null;
      });

  BaseClient _buildRetryClient(Client client, BaseClient httpClient) =>
      MatrixRefreshTokenClient(
        inner: FixedTimeoutHttpClient(
          httpClient,
          const Duration(seconds: 20),
        ),
        client: client,
      );
}

extension ClientIdentifier on String {
  int get clientIdentifier {
    final regex = RegExp(r'^\w+(\d+)$');
    final matches = regex.firstMatch(this);
    return int.parse(matches!.group(1)!);
  }
}
