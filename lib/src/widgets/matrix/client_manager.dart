import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart' hide GoRouterHelper;
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:olm/olm.dart' as olm;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/homeserver/homeserver.dart';
import '../../pages/room_list/room_list.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../utils/matrix/database/polycule_database_builder.dart';
import '../../utils/matrix/uia_helper.dart';
import 'key_verification/key_verification_request_widget.dart';
import 'uia_dialog.dart';

typedef GetClientCallback = Client Function();

class ClientManagerWidget extends StatefulWidget {
  const ClientManagerWidget({super.key, required this.child});

  factory ClientManagerWidget.routeBuilder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) =>
      ClientManagerWidget(child: child);

  final Widget child;

  @override
  State<ClientManagerWidget> createState() => ClientManager();
}

class ClientManager extends State<ClientManagerWidget> {
  static const _clientNamesKey = 'client_names';

  static String _makeClientName(int identifier) =>
      'polycule_client_$identifier';

  static List<Client> activeClients = [];

  static final _initializer = Completer<void>();

  static Client? getClientByIdentifier(int identifier) {
    return activeClients
        .where((client) => client.clientName.clientIdentifier == identifier)
        .singleOrNull;
  }

  bool _initializationStarted = false;

  Future<void>? waiForInitialization = _initializer.future;

  int _activeClientIdentifier = 1;

  @override
  void initState() {
    _loadClients();
    super.initState();
  }

  Future<void> _loadClients() async {
    if (_initializationStarted) {
      return _initializer.future;
    }
    _initializationStarted = true;

    if (!kIsWeb) {
      await _migrateLegacySqliteDatabasePath();
    }

    const storage = FlutterSecureStorage();
    final json = await storage.read(key: _clientNamesKey);
    if (json == null) {
      return;
    }
    final identifiers = (jsonDecode(json) as Iterable).whereType<int>();
    for (final identifier in identifiers) {
      activeClients.add(_buildClient(identifier));
    }
    if (activeClients.isEmpty) {
      activeClients.add(_buildClient(1));
      return;
    }

    setState(() {
      _activeClientIdentifier = identifiers.first;
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
      (client) => client.clientName.clientIdentifier == _activeClientIdentifier,
    );
    if (matchingClients.isNotEmpty) {
      return matchingClients.single;
    }

    return _buildNewClient();
  }

  @override
  Widget build(BuildContext context) => InheritedProvider<GetClientCallback>(
        create: (context) => getActiveClient,
        child: Builder(
          builder: (context) {
            return widget.child;
          },
        ),
      );

  @override
  void dispose() {
    for (var subscription in _loginStateListener.values) {
      subscription?.cancel();
    }
    for (var subscription in _uiaListener.values) {
      subscription?.cancel();
    }
    for (var subscription in _sasVerificationListener.values) {
      subscription?.cancel();
    }
    super.dispose();
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
          context.go(FatalErrorPage.routeName, extra: e);
          return;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(RoomListPage.routeName);
        });

        break;

      case LoginState.loggedOut:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go(HomeserverPage.routeName);
        });
        _removeFromClientList(client);
        break;
    }
  }

  Future<void> _handleUiaRequest(Client client, UiaRequest request) async {
    final handler = UiaHelper(
      client: getActiveClient(),
      request: request,
      authenticationPasswordCallback: (request) =>
          UiaDialog(request: request).show(context),
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
    const storage = FlutterSecureStorage();

    await client.dispose();

    activeClients
        .removeWhere((element) => element.clientName == client.clientName);

    final clientIdentifiers =
        activeClients.map((e) => e.clientName.clientIdentifier);
    await storage.write(
      key: _clientNamesKey,
      value: jsonEncode(clientIdentifiers),
    );

    setState(() {});
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

extension on String {
  int get clientIdentifier {
    final regex = RegExp(r'^\w+(\d+)$');
    final matches = regex.firstMatch(this);
    return int.parse(matches!.group(1)!);
  }
}
