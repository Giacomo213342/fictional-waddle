import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../runtime_suffix.dart';
import 'cipher.dart';
import 'idb/stub.dart' if (dart.library.js_interop) 'idb/web.dart';

import 'sqlcipher_stub.dart'
    if (dart.library.io) 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

Future<List<int>> discoverStoredClientIdentifiers({
  Directory? directory,
}) async {
  if (kIsWeb) {
    return const [];
  }
  final Directory supportDirectory;
  if (directory != null) {
    supportDirectory = directory;
  } else {
    final baseDirectory = await getApplicationSupportDirectory();
    supportDirectory = Directory(
      '${baseDirectory.path}${getRuntimeSuffix()}',
    );
  }
  if (!await supportDirectory.exists()) {
    return const [];
  }
  final pattern = RegExp(
    '^polycule_client_(\\d+)\\.sqlite(?:\\.broken)?\$',
  );
  final identifiers = <int>{};
  await for (final entity in supportDirectory.list()) {
    if (entity is! File) {
      continue;
    }
    final name = entity.uri.pathSegments.last;
    final match = pattern.firstMatch(name);
    final identifier = int.tryParse(match?.group(1) ?? '');
    if (identifier != null) {
      identifiers.add(identifier);
    }
  }
  return identifiers.toList()..sort();
}

Future<MatrixSdkDatabase> polyculeDatabaseBuilder(
  String clientName,
) async {
  if (kIsWeb) {
    final factory = createIdbFactory();
    return MatrixSdkDatabase.init(
      clientName,
      idbFactory: factory,
    );
  }

  final suffix = getRuntimeSuffix();

  final applicationCacheDirectory = await getApplicationCacheDirectory();
  final cacheDirectory = Directory(
    '${applicationCacheDirectory.path}$suffix/$clientName',
  );
  if (!await cacheDirectory.exists()) {
    await cacheDirectory.create(recursive: true);
  }

  final fileStorageLocation = Uri.file(cacheDirectory.path);
  final persistentAppDataDirectory = await getApplicationSupportDirectory();

  final databasePath =
      '${persistentAppDataDirectory.path}$suffix/$clientName.sqlite';
  final databaseFile = File(databasePath);
  final legacyBrokenFile = File('$databasePath.broken');
  final databaseExists = await databaseFile.exists();
  final brokenDatabaseExists = await legacyBrokenFile.exists();
  final cipher = await getDatabaseCipher(
    databaseExists: databaseExists || brokenDatabaseExists,
  );

  // fix dlopen for old Android
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

  // build a DB factory that supports SQLCipher
  databaseFactory = createDatabaseFactoryFfi(
    ffiInit: SQfLiteEncryptionHelper.ffiInit,
  );

  // initialize the encryption helper
  if (!databaseExists && brokenDatabaseExists) {
    await legacyBrokenFile.copy(databasePath);
    Logs()
        .w('Restored the preserved Matrix database after an interrupted open.');
  }

  Database database = await _openEncryptedDatabase(
    databasePath,
    cipher,
  );

  // Older Polycule builds replaced a temporarily locked database with an
  // empty one. Recover only when the current database has no session and the
  // preserved candidate is independently readable and authenticated.
  if (brokenDatabaseExists &&
      !await _containsStoredSession(database) &&
      await _candidateContainsStoredSession(legacyBrokenFile.path, cipher)) {
    await database.close();
    final backupPath =
        '$databasePath.empty-${DateTime.now().toUtc().microsecondsSinceEpoch}';
    await databaseFile.copy(backupPath);
    await _preserveSidecar('$databasePath-wal', '$backupPath-wal');
    await _preserveSidecar('$databasePath-shm', '$backupPath-shm');
    try {
      await legacyBrokenFile.copy(databasePath);
      database = await _openEncryptedDatabase(databasePath, cipher);
      if (!await _containsStoredSession(database)) {
        throw const FormatException(
          'The preserved Matrix database contains no stored session.',
        );
      }
      Logs().w('Recovered a Matrix session from the preserved database copy.');
    } catch (_) {
      await database.close().catchError((_) {});
      await File(backupPath).copy(databasePath);
      database = await _openEncryptedDatabase(databasePath, cipher);
      rethrow;
    }
  }

  return MatrixSdkDatabase.init(
    clientName,
    database: database,
    maxFileSize: 1024 * 1024 * 10,
    fileStorageLocation: fileStorageLocation,
    deleteFilesAfterDuration: const Duration(days: 30),
  );
}

Future<Database> _openEncryptedDatabase(String path, String cipher) async {
  final helper = SQfLiteEncryptionHelper(
    factory: databaseFactory,
    path: path,
    cipher: cipher,
  );
  try {
    await helper.ensureDatabaseFileEncrypted();
    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: helper.applyPragmaKey,
      ),
    );
  } catch (error, stackTrace) {
    final file = File(path);
    if (await file.exists()) {
      final evidencePath =
          '$path.failed-open-${DateTime.now().toUtc().microsecondsSinceEpoch}';
      await file.copy(evidencePath).catchError((_) => file);
    }
    Logs().wtf(
      'Matrix database open failed. The original database was preserved.',
      error,
      stackTrace,
    );
    rethrow;
  }
}

Future<bool> _candidateContainsStoredSession(
  String path,
  String cipher,
) async {
  Database? candidate;
  try {
    final helper = SQfLiteEncryptionHelper(
      factory: databaseFactory,
      path: path,
      cipher: cipher,
    );
    candidate = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        singleInstance: false,
        onConfigure: helper.applyPragmaKey,
      ),
    );
    return _containsStoredSession(candidate);
  } catch (_) {
    return false;
  } finally {
    await candidate?.close().catchError((_) {});
  }
}

Future<bool> _containsStoredSession(Database database) async {
  final tables = await database.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name = 'box_client'",
  );
  if (tables.isEmpty) {
    return false;
  }
  final rows = await database.query(
    'box_client',
    columns: const ['k'],
    where: 'k IN (?, ?, ?)',
    whereArgs: const ['homeserver_url', 'token', 'user_id'],
  );
  final keys = rows.map((row) => row['k']).whereType<String>().toSet();
  return keys.containsAll(const ['homeserver_url', 'token', 'user_id']);
}

Future<void> _preserveSidecar(String path, String backupPath) async {
  final sidecar = File(path);
  if (await sidecar.exists()) {
    await sidecar.rename(backupPath);
  }
}
