import 'dart:async';

import 'package:unifiedpush_storage_interface/distributor_storage.dart';
import 'package:unifiedpush_storage_interface/keys_storage.dart';
import 'package:unifiedpush_storage_interface/registrations_storage.dart';
import 'package:unifiedpush_storage_interface/storage.dart';

import '../secure_storage.dart';

class UnifiedPushStoragePolycule implements UnifiedPushStorage {
  @override
  DistributorStorage get distrib => DistributorStoragePolycule();

  @override
  FutureOr<void> init() {}

  @override
  KeysStorage get keys => KeysStoragePolycule();

  @override
  RegistrationsStorage get registrations => RegistrationsStoragePolycule();
}

// THIS CODE IS LARGELY COPIED FROM
// https://codeberg.org/UnifiedPush/flutter-connector/src/branch/main/unifiedpush_storage_shared_preferences/lib/storage.dart

class DistributorStoragePolycule extends DistributorStorage {
  static const String _ack = 'unifiedpush.distributor.ack';
  static const String _name = 'unifiedpush.distributor.name';

  @override
  FutureOr<void> ack() {
    return kPolyculeSecureStorage.write(key: _ack, value: 'true');
  }

  @override
  FutureOr<String?> get() {
    return kPolyculeSecureStorage.read(key: _name);
  }

  @override
  FutureOr<void> remove() async {
    await kPolyculeSecureStorage.delete(key: _ack);
    await kPolyculeSecureStorage.delete(key: _name);
  }

  @override
  FutureOr<void> set(String distributor) async {
    final current = get();
    if (current != distributor) {
      await kPolyculeSecureStorage.delete(key: _ack);
    }
    return kPolyculeSecureStorage.write(key: _name, value: distributor);
  }
}

class KeysStoragePolycule extends KeysStorage {
  static const String _key = 'unifiedpush.key';

  @override
  FutureOr<String?> get(String instance) {
    return kPolyculeSecureStorage.read(key: '$_key.$instance');
  }

  @override
  FutureOr<void> remove(String instance) {
    return kPolyculeSecureStorage.delete(key: '$_key.$instance');
  }

  @override
  FutureOr<void> set(String instance, String serializedKey) {
    return kPolyculeSecureStorage.write(
      key: '$_key.$instance',
      value: serializedKey,
    );
  }
}

class RegistrationsStoragePolycule extends RegistrationsStorage {
  /// To get instance from token
  static const String _instanceFor = 'unifiedpush.instance_for';

  /// To get token from instance
  static const String _tokenFor = 'unifiedpush.token_for';

  @override
  FutureOr<TokenInstance?> getFromInstance(String instance) async {
    final token =
        await kPolyculeSecureStorage.read(key: '$_tokenFor.$instance');
    if (token == null) {
      return null;
    }
    return TokenInstance(token, instance);
  }

  @override
  FutureOr<TokenInstance?> getFromToken(String token) async {
    final instance =
        await kPolyculeSecureStorage.read(key: '$_instanceFor.$token');
    if (instance == null) {
      return null;
    }
    return TokenInstance(token, instance);
  }

  @override
  FutureOr<bool> remove(String instance) async {
    final token =
        await kPolyculeSecureStorage.read(key: '$_tokenFor.$instance');
    if (token != null) {
      await kPolyculeSecureStorage.delete(key: '$_instanceFor.$token');
    }
    await kPolyculeSecureStorage.delete(key: '$_tokenFor.$instance');
    return (await kPolyculeSecureStorage.readAll())
        .keys
        .any((it) => it.startsWith(_instanceFor));
  }

  @override
  FutureOr<void> removeAll() async {
    final keys = (await kPolyculeSecureStorage.readAll()).keys;
    for (final key in keys) {
      if (key.startsWith(_instanceFor) || key.startsWith(_tokenFor)) {
        await kPolyculeSecureStorage.delete(key: key);
      }
    }
  }

  @override
  FutureOr<void> save(TokenInstance token) async {
    await kPolyculeSecureStorage.write(
      key: '$_instanceFor.${token.token}',
      value: token.instance,
    );
    await kPolyculeSecureStorage.write(
      key: '$_tokenFor.${token.instance}',
      value: token.token,
    );
  }
}
