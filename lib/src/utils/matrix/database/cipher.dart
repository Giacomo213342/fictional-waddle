import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:matrix/matrix.dart';

import '../../runtime_suffix.dart';

const _cipherStorageKey = 'database_cipher';

Future<String> getDatabaseCipher() async {
  String? cipher;

  final suffix = getRuntimeSuffix();

  try {
    const secureStorage = FlutterSecureStorage();
    cipher = await secureStorage.read(key: _cipherStorageKey + suffix);
    if (cipher != null) {
      return cipher;
    }

    // looks like no cipher stored yet
    final rng = Random.secure();
    final list = Uint8List(32);
    list.setAll(0, Iterable.generate(list.length, (i) => rng.nextInt(256)));
    final newCipher = base64UrlEncode(list);
    await secureStorage.write(
      key: _cipherStorageKey + suffix,
      value: newCipher,
    );

    // workaround for if we just wrote to the key and it still doesn't exist
    cipher = await secureStorage.read(key: _cipherStorageKey + suffix);
    if (cipher == null) {
      throw MissingPluginException();
    }
  } on MissingPluginException catch (_) {
    const FlutterSecureStorage()
        .delete(key: _cipherStorageKey + suffix)
        .catchError((_) {});
    Logs().i('Database encryption is not supported on this platform');
  } catch (e, s) {
    const FlutterSecureStorage()
        .delete(key: _cipherStorageKey + suffix)
        .catchError((_) {});
    Logs().w('Unable to init database encryption', e, s);
  }

  // with the new database, we should no longer allow unencrypted storage
  // secure_storage now supports all platforms we support
  if (cipher == null) {
    throw CouldNotStoreCipherError();
  }

  return cipher;
}

class CouldNotStoreCipherError extends Error {}
