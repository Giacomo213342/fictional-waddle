import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:olm/olm.dart' as olm;

import '../../../pages/fatal_error/fatal_error_page.dart';
import '../../../pages/homeserver/homeserver.dart';
import '../../../pages/room_list/room_list.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../scopes/client_scope.dart';
import 'client_manager.dart';
import 'client_store.dart';

class LoginStateListener extends StatefulWidget {
  const LoginStateListener({super.key, required this.child});

  final Widget child;

  @override
  State<LoginStateListener> createState() => _LoginStateListenerState();
}

class _LoginStateListenerState extends State<LoginStateListener> {
  static String? _olmVersion;

  StreamSubscription<LoginState>? _subscription;

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void didChangeDependencies() {
    _subscription?.cancel();
    _subscription = ClientScope.of(context)
        .client
        .onLoginStateChanged
        .stream
        .listen(_handleLoginState);
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _handleLoginState(LoginState event) {
    final client = ClientScope.of(context).client;

    // do not handle login state changes if client was disposed
    if (!ClientManager.of(context).store.activeClients.value.any(
          (c) =>
              client.clientName.clientIdentifier ==
              client.clientName.clientIdentifier,
        )) {
      return;
    }

    Logs().v(
      'Login state $event for '
      'client ${ClientScope.of(context).client.clientName.clientIdentifier}',
    );
    switch (event) {
      case LoginState.loggedIn:
        // under no case start the app if encryption not supported
        // This should prevent from CI accidentally forgetting to bundle OLM
        if (_olmVersion == null) {
          try {
            _olmVersion = olm.get_library_version().join('.');
            Logs().d('Running with OLM version $_olmVersion');
          } on ArgumentError catch (e, s) {
            Logs().wtf('Unable to load OLM.', e, s);
            ClientScope.of(context).client.dispose();

            context.goMultiClient(FatalErrorPage.routeName, extra: e);
            rethrow;
          }
        }

        context.goMultiClient(RoomListPage.routeName);
        break;
      case LoginState.loggedOut:
        context.goMultiClient(HomeserverPage.routeName);

        break;
      case LoginState.softLoggedOut:
        break;
    }
  }
}
