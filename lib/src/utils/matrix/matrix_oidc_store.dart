import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matrix/matrix.dart';
import 'package:oidc/oidc.dart';

// based on https://github.com/Bdaya-Dev/oidc/blob/main/packages/oidc_default_store/lib/src/oidc_default_store.dart
class MatrixOidcStore implements OidcStore {
  MatrixOidcStore({
    FlutterSecureStorage? secureStorageInstance,
    required Client client,
  })  : _secureStorage = secureStorageInstance ?? const FlutterSecureStorage(),
        storagePrefix = '${client.clientName}_oidc';
  final FlutterSecureStorage _secureStorage;

  final String? storagePrefix;

  String _getKey(OidcStoreNamespace namespace, String key) {
    return [storagePrefix, namespace.value, key].whereType<String>().join('.');
  }

  String _getNamespaceKeys(OidcStoreNamespace namespace) {
    return [storagePrefix, 'keys', namespace.value]
        .whereType<String>()
        .join('.');
  }

  @override
  Future<void> init() async {}

  @override
  Future<Set<String>> getAllKeys(OidcStoreNamespace namespace) async {
    final keysRaw =
        await _secureStorage.read(key: _getNamespaceKeys(namespace));
    if (keysRaw == null) {
      return <String>{};
    }
    return (jsonDecode(keysRaw) as List).cast<String>().toSet();
  }

  @override
  Future<Map<String, String>> getMany(
    OidcStoreNamespace namespace, {
    required Set<String> keys,
  }) async {
    final map = <String, String>{};
    for (final key in keys) {
      final value = await _secureStorage.read(key: _getKey(namespace, key));
      if (value == null) {
        continue;
      }
      map[key] = value;
    }
    return map;
  }

  @override
  Future<void> setMany(
    OidcStoreNamespace namespace, {
    required Map<String, String> values,
  }) async {
    for (final entry in values.entries) {
      await _secureStorage.write(
        key: _getKey(namespace, entry.key),
        value: entry.value,
      );
    }
  }

  @override
  Future<void> removeMany(
    OidcStoreNamespace namespace, {
    required Set<String> keys,
  }) async {
    for (final key in keys) {
      await _secureStorage.delete(key: _getKey(namespace, key));
    }
  }
}
