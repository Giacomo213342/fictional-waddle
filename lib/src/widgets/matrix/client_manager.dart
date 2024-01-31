import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:olm/olm.dart' as olm;
import 'package:provider/provider.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/homeserver/homeserver.dart';
import '../../pages/room_list/room_list.dart';
import '../../utils/matrix/database/polycule_database_builder.dart';
import '../../utils/matrix/uia_helper.dart';
import 'key_verification/key_verification_request_widget.dart';
import 'uia_dialog.dart';

class ClientManagerWidget extends StatefulWidget {
  const ClientManagerWidget({super.key, required this.child});

  factory ClientManagerWidget.routeBuilder(
    BuildContext context,
    GoRouterState state,
    Widget child,
  ) =>
      ClientManagerWidget(child: child);

  final Widget? child;

  @override
  State<ClientManagerWidget> createState() => ClientManager();
}

class ClientManager extends State<ClientManagerWidget> {
  static Client? activeClient;

  // TODO: map multi client listeners
  StreamSubscription<LoginState>? _loginStateListener;

  StreamSubscription<UiaRequest>? _uiaListener;

  StreamSubscription<KeyVerification>? _sasVerificationListener;

  Client buildClient(String name) {
    final client = Client(
      name,
      databaseBuilder: polyculeDatabaseBuilder,
      verificationMethods: {
        KeyVerificationMethod.numbers,
        KeyVerificationMethod.reciprocate,
      },
      nativeImplementations: kIsWeb
          ? NativeImplementationsWebWorker(Uri.parse('web_worker.dart.js'))
          : NativeImplementationsIsolate(compute),
    );
    _loginStateListener?.cancel();
    _loginStateListener =
        client.onLoginStateChanged.stream.listen(_handleLoginStateChange);
    _uiaListener?.cancel();
    _uiaListener = client.onUiaRequest.stream.listen(_handleUiaRequest);
    _sasVerificationListener?.cancel();
    _sasVerificationListener = client.onKeyVerificationRequest.stream
        .listen(_handleSasVerificationRequest);
    return client;
  }

  Client getActiveClient() {
    Client? client = activeClient;
    // TODO: fetch client list from database for multi account support
    return client ??= activeClient = buildClient('polycule');
  }

  @override
  Widget build(BuildContext context) => InheritedProvider<Client>(
        create: (context) => getActiveClient(),
        child: widget.child,
      );

  @override
  void dispose() {
    _loginStateListener?.cancel();
    _uiaListener?.cancel();
    _sasVerificationListener?.cancel();
    super.dispose();
  }

  void _handleLoginStateChange(LoginState state) {
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
        break;
    }
  }

  Future<void> _handleUiaRequest(UiaRequest request) async {
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
}
