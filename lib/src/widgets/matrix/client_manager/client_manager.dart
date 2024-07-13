import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:olm/olm.dart' as olm;
import 'package:path_provider/path_provider.dart';

import '../../../pages/application_settings/application_settings.dart';
import '../../../pages/fatal_error/fatal_error_page.dart';
import '../../../pages/homeserver/homeserver.dart';
import '../../../pages/room_list/room_list.dart';
import '../../../pages/splash_screen/splash_screen.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../utils/matrix/database/polycule_database_builder.dart';
import '../../../utils/matrix/uia_helper.dart';
import '../../../utils/runtime_suffix.dart';
import '../key_verification/key_verification_request_widget.dart';
import '../uia_dialog.dart';
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
            ClientManager.extractClientIdentifierFromRoute(state) ?? 1,
        child: child,
      );

  final int activeClientIdentifier;
  final Widget child;

  @override
  State<ClientManagerWidget> createState() => ClientManager();
}

class ClientManager extends State<ClientManagerWidget> with RouteAware {
  static const _clientNamesKey = 'client_names';

  static const _storageLockKey = 'storage_lock';

  static String _makeClientName(int identifier) =>
      'polycule_client_$identifier';

  static List<Client> activeClients = [];

  static final _initializer = Completer<void>();

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

  Future<void>? waiForInitialization = _initializer.future;

  final suffix = getRuntimeSuffix();

  @override
  void initState() {
    _loadClients();
    super.initState();
  }

  Future<void> _loadClients() async {
    if (activeClients.isNotEmpty) {
      return;
    }
    if (_initializationStarted) {
      return _initializer.future;
    }
    _initializationStarted = true;

    if (!kIsWeb) {
      await _migrateLegacySqliteDatabasePath();
    }

    final future = storageLock?.future;
    if (future != null) {
      log(
        'Storage locked. Waiting with client initialization.',
        name: _storageLockKey,
      );
      await future;
    }
    log(
      'Acquiring storage lock for client initialization.',
      name: _storageLockKey,
    );
    storageLock = Completer<void>();

    const storage = FlutterSecureStorage();
    final json = await storage.read(key: _clientNamesKey + suffix);
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
    log(
      'Released storage lock after initialization. '
      '${activeClients.length} clients running.',
      name: _storageLockKey,
    );

    setState(() {
      _initializer.complete();
    });
  }

  final Map<int, StreamSubscription<LoginState>?> _loginStateListener = {};

  final Map<int, StreamSubscription<UiaRequest>?> _uiaListener = {};

  final Map<int, StreamSubscription<KeyVerification>?>
      _sasVerificationListener = {};

  Client _buildClient(int identifier) {
    final client = Client(
      _makeClientName(identifier),
      databaseBuilder: polyculeDatabaseBuilder,
      verificationMethods: {
        KeyVerificationMethod.numbers,
        KeyVerificationMethod.reciprocate,
      },
      nativeImplementations: kIsWeb
          ? NativeImplementationsWebWorker(Uri.parse('web_worker.dart.js'))
          : NativeImplementationsIsolate(compute),
    );

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

  Client getActiveClient() {
    final matchingClients = activeClients.where(
      (client) =>
          client.clientName.clientIdentifier == widget.activeClientIdentifier,
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
  Widget build(BuildContext context) => ClientManagerView(this);

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
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ClientManagerWidget oldWidget) {
    if (oldWidget.activeClientIdentifier != widget.activeClientIdentifier) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleLoginStateChange(Client client, LoginState state) {
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
            getActiveClient().clientName.clientIdentifier) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goMultiClient(RoomListPage.routeName);
          });
        }

        _ensureClientInDb(client);

        break;

      case LoginState.softLoggedOut:
      case LoginState.loggedOut:
        if (client.clientName.clientIdentifier ==
            getActiveClient().clientName.clientIdentifier) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.goMultiClient(HomeserverPage.routeName);
          });
        }
        _removeFromClientList(client);
        break;
    }
  }

  Future<void> _handleUiaRequest(Client client, UiaRequest request) async {
    final handler = UiaHelper(
      client: getActiveClient(),
      request: request,
      authenticationPasswordCallback: (request) => UiaDialog(
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
    if (activeClients.length <= 1 ||
        _loginClients.contains(client.clientName.clientIdentifier)) {
      return;
    }

    final future = storageLock?.future;
    if (future != null) {
      log(
        'Storage locked. Waiting with client deletion.',
        name: _storageLockKey,
      );
      await future;
    }
    log(
      'Acquiring storage lock for client deletion.',
      name: _storageLockKey,
    );
    storageLock = Completer<void>();

    const storage = FlutterSecureStorage();

    final identifier = client.clientName.clientIdentifier;

    await client.dispose();

    setState(() {
      activeClients.removeWhere(
        (element) => element.clientName.clientIdentifier == identifier,
      );
    });

    final clientIdentifiers =
        activeClients.map((e) => e.clientName.clientIdentifier);
    await storage.write(
      key: _clientNamesKey + suffix,
      value: jsonEncode(clientIdentifiers.toList()),
    );
    storageLock?.complete();
    storageLock = null;

    log(
      'Released storage lock for client deletion.',
      name: _storageLockKey,
    );

    if (widget.activeClientIdentifier == identifier) {
      final newIdentifier = activeClients.first.clientName.clientIdentifier;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.goMultiClient('/client/$newIdentifier${SplashPage.routeName}');
      });
    }
  }

  Future<void> _ensureClientInDb(Client client) async {
    final identifier = client.clientName.clientIdentifier;
    setState(() {
      _loginClients.remove(identifier);
    });

    final future = storageLock?.future;
    if (future != null) {
      log(
        'Storage locked. Waiting to store the new client.',
        name: _storageLockKey,
      );
      await future;
    }
    log(
      'Acquiring storage lock in order to store the new client.',
      name: _storageLockKey,
    );
    storageLock = Completer<void>();

    const storage = FlutterSecureStorage();

    final storedJson = await storage.read(
      key: _clientNamesKey + suffix,
    );

    Set<int> identifiers = {};

    if (storedJson is String) {
      identifiers.addAll((jsonDecode(storedJson) as Iterable).whereType<int>());
    }
    if (!identifiers.contains(identifier)) {
      identifiers.add(identifier);

      await storage.write(
        key: _clientNamesKey + suffix,
        value: jsonEncode(identifiers.toList()),
      );
    }
    storageLock?.complete();
    storageLock = null;

    log(
      'Released storage lock after storing the new client.',
      name: _storageLockKey,
    );
  }

  Future<void> closeLoginClient(Client client) async {
    _loginClients.remove(client.clientName.clientIdentifier);

    await _removeFromClientList(client);
  }

  void openSettings() {
    context.push(ApplicationSettingsPage.routeName);
  }
}

Future<void> _migrateLegacySqliteDatabasePath() async {
  final fileStoragePath = await getApplicationSupportDirectory();
  final legacyPath = '${fileStoragePath.path}/polycule.sqlite';
  final newPath = '${fileStoragePath.path}/polycule_client_1.sqlite';

  final legacyFile = File(legacyPath);
  if (!await legacyFile.exists()) {
    return;
  }

  await legacyFile.copy(newPath);
  if (!await File(newPath).exists()) {
    return;
  }

  await legacyFile.delete();
}

extension ClientIdentifier on String {
  int get clientIdentifier {
    final regex = RegExp(r'^\w+(\d+)$');
    final matches = regex.firstMatch(this);
    return int.parse(matches!.group(1)!);
  }
}
