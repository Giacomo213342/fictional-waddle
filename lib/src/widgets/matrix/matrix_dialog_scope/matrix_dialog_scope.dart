import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';

import '../../../utils/matrix/uia_helper.dart';
import '../client_manager/client_manager.dart';
import '../client_manager/client_store.dart';
import '../key_verification/key_verification_request_widget.dart';
import '../uia/uia_oidc_account_management_dialog.dart';
import '../uia/uia_password_dialog.dart';

class MatrixDialogScope extends StatefulWidget {
  const MatrixDialogScope({super.key, required this.child});

  final Widget child;

  @override
  State<MatrixDialogScope> createState() => _MatrixDialogScopeState();
}

class _MatrixDialogScopeState extends State<MatrixDialogScope> {
  ValueNotifier<List<Client>>? _clients;

  final Map<int, StreamSubscription<UiaRequest>?> _uiaListener = {};

  final Map<int, StreamSubscription<KeyVerification>?>
      _sasVerificationListener = {};

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final clients = _clients = ClientManager.of(context).store.activeClients;
    _handleClients();
    clients.addListener(_handleClients);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (_clients == null) {
      final clients = _clients = ClientManager.of(context).store.activeClients;
      _handleClients();
      clients.addListener(_handleClients);
    }
    return widget.child;
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

  void _handleClients() {
    final clients = _clients;
    if (clients == null) {
      return;
    }

    for (final client in clients.value) {
      final identifier = client.clientName.clientIdentifier;

      _uiaListener[identifier]?.cancel();
      _uiaListener[identifier] = client.onUiaRequest.stream.listen(
        (request) => _handleUiaRequest(client, request),
      );
      _sasVerificationListener[identifier]?.cancel();
      _sasVerificationListener[identifier] = client
          .onKeyVerificationRequest.stream
          .listen((request) => _handleSasVerificationRequest(client, request));
    }
  }

  void _unsubscribe() {
    for (final subscription in _uiaListener.values) {
      subscription?.cancel();
    }
    for (final subscription in _sasVerificationListener.values) {
      subscription?.cancel();
    }
    _clients?.removeListener(_handleClients);
  }
}
