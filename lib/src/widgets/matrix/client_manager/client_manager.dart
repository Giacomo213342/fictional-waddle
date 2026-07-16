import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/client_util.dart';
import '../../../utils/matrix/polycule_command_extension.dart';
import '../../../utils/matrix/push_manager.dart';
import '../../../utils/polycule_http_client/polycule_http_client.dart';
import '../../error_dialog_scope.dart';
import '../../intent_manager.dart';
import 'client_store.dart';

import '../../../utils/matrix/database/idb/stub.dart'
    if (dart.library.js_interop) '../../../utils/matrix/database/idb/web.dart';

typedef GetClientCallback = Client Function();

class ClientManagerRoot extends StatefulWidget {
  const ClientManagerRoot({super.key, required this.child});

  final Widget child;

  @override
  State<ClientManagerRoot> createState() => ClientManager();
}

class _ClientManagerScope extends InheritedWidget {
  const _ClientManagerScope({required this.manager, required super.child});

  final ClientManager manager;

  @override
  bool updateShouldNotify(covariant _ClientManagerScope oldWidget) =>
      !listEquals(
        manager.store.activeClients.value,
        oldWidget.manager.store.activeClients.value,
      ) ||
      !listEquals(
        manager._loginClients.toList(),
        oldWidget.manager._loginClients.toList(),
      );
}

class ClientManager extends State<ClientManagerRoot> with RouteAware {
  static ClientManager of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_ClientManagerScope>()!
      .manager;

  String _makeClientName(int identifier) => 'polycule_client_$identifier';

  Client? getClientByIdentifier(int identifier) {
    return store.activeClients.value
        .where((client) => client.clientName.clientIdentifier == identifier)
        .singleOrNull;
  }

  final _loginClients = <int>{};

  late ClientStore store;

  final Map<int, StreamSubscription<LoginState>?> _loginStateListener = {};

  final Map<int, PushManager> pushManagers = {};

  StreamSubscription<ClientCallback>? _httpClientListener;

  ClientCallback? _httpClient;

  @override
  void initState() {
    IntentManager.clientsReady.value = false;
    store = ClientStore(buildClient: _buildClient);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadClients());
    super.initState();
  }

  @override
  void dispose() {
    for (final subscription in _loginStateListener.values) {
      subscription?.cancel();
    }
    _httpClientListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ErrorDialogScope(
        child: IntentManagerWidget(
          child: _ClientManagerScope(manager: this, child: widget.child),
        ),
      );

  Future<void> moveClient(Client client, int index) async {
    await store.moveClient(client, index);
  }

  Future<int> addLoginClient() async {
    final client = await store.buildNewClient();
    final identifier = client.clientName.clientIdentifier;
    _loginClients.add(identifier);
    return identifier;
  }

  Future<void> closeLoginClient(Client client) async {
    _loginClients.remove(client.clientName.clientIdentifier);

    await _removeFromClientList(client);
  }

  Future<Client> _buildClient(int identifier) async {
    final httpClient = _httpClient!.call();
    final client = await ClientUtil.clientConstructor(
      _makeClientName(identifier),
      httpClient,
    );

    client.registerPolyculeCommands();

    _loginStateListener[identifier]?.cancel();
    _loginStateListener[identifier] = client.onLoginStateChanged.stream.listen(
      (loginState) => _handleLoginStateChange(client, loginState),
    );

    await client.init(waitForFirstSync: false);
    pushManagers[identifier] = PushManager(client);
    return client;
  }

  Future<void> _handleLoginStateChange(Client client, LoginState state) async {
    switch (state) {
      case LoginState.softLoggedOut:
      // we let the SDK handle soft log out
      case LoginState.loggedIn:
        if (_loginClients.contains(client.clientName.clientIdentifier)) {
          _ensureClientInDb(client);
        }
        unawaited(persistStorage());

        break;
      case LoginState.loggedOut:
        if (!_loginClients.contains(client.clientName.clientIdentifier)) {
          await _removeFromClientList(client);
        }
        break;
    }
  }

  Future<bool> _loadClients() async {
    // first ensure we have an HTTP client
    _httpClient = await PolyculeHttpClientManager.httpClientCallback;
    _httpClientListener = PolyculeHttpClientManager.httpClientCallbackStream
        .listen(_updateHttpClients);

    await store.loadClients();
    IntentManager.clientsReady.value = true;
    return true;
  }

  Future<void> _removeFromClientList(Client client) async {
    // if it's the only client left, we need to keep it running
    if (store.activeClients.value.length <= 1) {
      return;
    }

    await store.deleteClient(client);

    if (!mounted) {
      return;
    }
  }

  Future<void> _ensureClientInDb(Client client) async {
    final identifier = client.clientName.clientIdentifier;
    _loginClients.remove(identifier);
    await store.storeClient(client);
  }

  Future<void> _updateHttpClients(ClientCallback httpClientCallback) async {
    _httpClient = httpClientCallback;
    for (final client in store.activeClients.value) {
      client.httpClient.close();
      client.httpClient = ClientUtil.buildRetryClient(
        client,
        httpClientCallback.call(),
      );
    }
  }
}
