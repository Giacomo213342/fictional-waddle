import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import '../../runtime_suffix.dart';
import '../../secure_storage.dart';

const _cipherStorageKey = 'database_cipher';

class MissingDatabaseCipherError implements Exception {
  const MissingDatabaseCipherError();

  @override
  String toString() =>
      'The Matrix database exists but its encryption key is unavailable.';
}

class CouldNotStoreCipherError implements Exception {
  const CouldNotStoreCipherError();

  @override
  String toString() =>
      'The Matrix database encryption key could not be stored.';
}

typedef SecureValueReader = Future<String?> Function(String key);
typedef SecureValueWriter = Future<void> Function(String key, String value);

Future<String> getDatabaseCipher({
  required bool databaseExists,
  SecureValueReader? read,
  SecureValueWriter? write,
}) async {
  read ??= (key) => kPolyculeSecureStorage.read(key: key);
  write ??=
      (key, value) => kPolyculeSecureStorage.write(key: key, value: value);

  final suffix = getRuntimeSuffix();
  final key = _cipherStorageKey + suffix;
  final cipher = await read(key);
  if (cipher != null) {
    return cipher;
  }

  // Generating a replacement key for an existing encrypted database would
  // make the account permanently unreadable. Surface the storage failure and
  // preserve every byte instead.
  if (databaseExists) {
    throw const MissingDatabaseCipherError();
  }

  final rng = Random.secure();
  final bytes = Uint8List(32);
  bytes.setAll(0, Iterable.generate(bytes.length, (_) => rng.nextInt(256)));
  final newCipher = base64UrlEncode(bytes);
  await write(key, newCipher);

  final storedCipher = await read(key);
  if (storedCipher == null) {
    throw const CouldNotStoreCipherError();
  }
  return storedCipher;
}
