import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../../../utils/error_logger.dart';
import '../../../utils/runtime_suffix.dart';
import '../../../utils/secure_storage.dart';

typedef BuildClientCallback = Future<Client> Function(int index);

class ClientStore {
  ClientStore({required this.buildClient});

  static const _clientNamesKey = 'client_names';
  static final suffix = getRuntimeSuffix();

  final _initializer = Completer<bool>();
  Completer<void>? storageLock;

  Future<void> get waiForInitialization => _initializer.future;

  final BuildClientCallback buildClient;

  ValueNotifier<List<Client>> activeClients = ValueNotifier(const []);

  bool _initializationStarted = false;

  Future<bool> loadClients() async {
    if (this.activeClients.value.isNotEmpty) {
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

    final activeClients = List<Client>.from(this.activeClients.value);
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
          activeClients.add(await buildClient(identifier));
        }
      }
    }
    if (activeClients.isEmpty) {
      activeClients.add(await buildClient(1));
    }
    this.activeClients.value = activeClients;
    storageLock?.complete();
    storageLock = null;
    Logs().d(
      'Released storage lock after initialization. '
      '${activeClients.length} clients running.',
    );

    _initializer.complete(true);
    return true;
  }

  Future<void> moveClient(Client client, int index) async {
    final future = storageLock?.future;
    if (future != null) {
      Logs().d(
        'Storage locked. Waiting with moving clients.',
      );
      await future;
    }
    Logs().d(
      'Acquiring storage lock for moving clients.',
    );
    storageLock = Completer<void>();

    final identifier = client.clientName.clientIdentifier;

    final activeClients = List<Client>.from(this.activeClients.value);
    final oldIndex = activeClients.indexWhere(
      (element) => element.clientName.clientIdentifier == identifier,
    );
    if (oldIndex <= index) {
      index--;
    }

    activeClients.removeAt(oldIndex);
    activeClients.insert(index, client);

    final clientIdentifiers =
        activeClients.map((e) => e.clientName.clientIdentifier);
    await kPolyculeSecureStorage.write(
      key: _clientNamesKey + suffix,
      value: jsonEncode(clientIdentifiers.toList()),
    );
    storageLock?.complete();
    storageLock = null;

    this.activeClients.value = activeClients;

    Logs().d(
      'Released storage lock for moving clients.',
    );
  }

  Future<void> deleteClient(Client client) async {
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

    final activeClients = List<Client>.from(this.activeClients.value);

    activeClients.removeWhere(
      (element) => element.clientName.clientIdentifier == identifier,
    );

    final clientIdentifiers =
        activeClients.map((e) => e.clientName.clientIdentifier);
    await kPolyculeSecureStorage.write(
      key: _clientNamesKey + suffix,
      value: jsonEncode(clientIdentifiers.toList()),
    );
    storageLock?.complete();
    storageLock = null;

    this.activeClients.value = activeClients;

    await kPolyculeSecureStorage.delete(
      key: SsssBootstrapController.ssssKeyStorage(client),
    );

    await client.database.delete();

    await client.dispose();

    Logs().d(
      'Released storage lock for client deletion.',
    );
  }

  Future<void> storeClient(Client client) async {
    final identifier = client.clientName.clientIdentifier;

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

  Future<Client> buildNewClient() async {
    final activeClients = List<Client>.from(this.activeClients.value);
    final identifiers = activeClients
        .map((e) => e.clientName.clientIdentifier)
        .toList()
      ..sort();
    final identifier = identifiers.isEmpty ? 1 : identifiers.last + 1;
    final client = await buildClient(identifier);
    activeClients.add(client);
    this.activeClients.value = activeClients;
    return client;
  }
}

extension ClientIdentifier on String {
  int get clientIdentifier {
    final regex = RegExp(r'^\w+(\d+)$');
    final matches = regex.firstMatch(this);
    return int.parse(matches!.group(1)!);
  }
}
