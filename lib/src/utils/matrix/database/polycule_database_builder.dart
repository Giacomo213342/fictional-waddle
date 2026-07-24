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

const _recoverySnapshotAge = Duration(hours: 6);
const _primaryRecoverySuffix = '.recovery-1';
const _secondaryRecoverySuffix = '.recovery-2';

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

  Database database = await _openEncryptedDatabaseWithRecovery(
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
      database = await _openEncryptedDatabaseWithRecovery(
        databasePath,
        cipher,
      );
      if (!await _containsStoredSession(database)) {
        throw const FormatException(
          'The preserved Matrix database contains no stored session.',
        );
      }
      Logs().w('Recovered a Matrix session from the preserved database copy.');
    } catch (_) {
      await database.close().catchError((_) {});
      await File(backupPath).copy(databasePath);
      database = await _openEncryptedDatabaseWithRecovery(
        databasePath,
        cipher,
      );
      rethrow;
    }
  }

  await _createRecoverySnapshot(database, databasePath, cipher);

  return MatrixSdkDatabase.init(
    clientName,
    database: database,
    maxFileSize: 1024 * 1024 * 10,
    fileStorageLocation: fileStorageLocation,
    deleteFilesAfterDuration: const Duration(days: 30),
  );
}

Future<Database> _openEncryptedDatabaseWithRecovery(
  String path,
  String cipher,
) async {
  Database? database;
  Object? originalError;
  StackTrace? originalStackTrace;
  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      database = await _openEncryptedDatabase(path, cipher);
      if (!await _databaseIsHealthy(database)) {
        throw const FormatException('Matrix database quick_check failed.');
      }
      return database;
    } catch (error, stackTrace) {
      originalError = error;
      originalStackTrace = stackTrace;
      await database?.close().catchError((_) {});
      database = null;
      if (!_isTransientDatabaseError(error) || attempt == 2) {
        break;
      }
      await Future<void>.delayed(Duration(milliseconds: 150 * (attempt + 1)));
    }
  }

  if (_isRecoverableDatabaseDamage(originalError) &&
      await _restoreRecoverySnapshot(path, cipher)) {
    final recovered = await _openEncryptedDatabase(path, cipher);
    if (await _databaseIsHealthy(recovered) &&
        await _containsStoredSession(recovered)) {
      Logs().w('Recovered the Matrix store from a verified snapshot.');
      return recovered;
    }
    await recovered.close().catchError((_) {});
  }

  await _preserveFailedDatabase(path);
  Logs().wtf(
    'Matrix database open failed. The original database was preserved.',
    originalError,
    originalStackTrace,
  );
  Error.throwWithStackTrace(originalError!, originalStackTrace!);
}

bool _isTransientDatabaseError(Object? error) {
  final message = error.toString().toLowerCase();
  return message.contains('database is locked') ||
      message.contains('database is busy') ||
      message.contains('database is closed') ||
      message.contains('cannot start a transaction');
}

bool _isRecoverableDatabaseDamage(Object? error) {
  if (error is FormatException) {
    return true;
  }
  final message = error.toString().toLowerCase();
  return message.contains('database disk image is malformed') ||
      message.contains('file is not a database') ||
      message.contains('database corruption');
}

Future<Database> _openEncryptedDatabase(
  String path,
  String cipher, {
  bool reliabilityPragmas = true,
}) async {
  final helper = SQfLiteEncryptionHelper(
    factory: databaseFactory,
    path: path,
    cipher: cipher,
  );
  await helper.ensureDatabaseFileEncrypted();
  return databaseFactory.openDatabase(
    path,
    options: OpenDatabaseOptions(
      version: 1,
      singleInstance: reliabilityPragmas,
      onConfigure: (database) async {
        await helper.applyPragmaKey(database);
        await database.execute('PRAGMA busy_timeout = 15000');
        if (reliabilityPragmas) {
          await database.rawQuery('PRAGMA journal_mode = WAL');
          await database.execute('PRAGMA synchronous = FULL');
          await database.execute('PRAGMA wal_autocheckpoint = 500');
          await database.execute('PRAGMA foreign_keys = ON');
        }
      },
    ),
  );
}

Future<bool> _databaseIsHealthy(Database database) async {
  try {
    final rows = await database.rawQuery('PRAGMA quick_check(1)');
    return rows.length == 1 &&
        rows.single.values.length == 1 &&
        rows.single.values.single.toString().toLowerCase() == 'ok';
  } catch (_) {
    return false;
  }
}

Future<bool> _restoreRecoverySnapshot(String path, String cipher) async {
  for (final suffix in const [
    _primaryRecoverySuffix,
    _secondaryRecoverySuffix,
  ]) {
    final snapshot = File('$path$suffix');
    if (!await snapshot.exists() ||
        !await _candidateContainsStoredSession(snapshot.path, cipher)) {
      continue;
    }

    final staged = File('$path.recovering');
    try {
      await snapshot.copy(staged.path);
      if (!await _candidateContainsStoredSession(staged.path, cipher)) {
        await staged.delete().catchError((_) => staged);
        continue;
      }
      final evidenceSuffix =
          '.failed-${DateTime.now().toUtc().microsecondsSinceEpoch}';
      await _moveIfPresent(path, '$path$evidenceSuffix');
      await _moveIfPresent('$path-wal', '$path$evidenceSuffix-wal');
      await _moveIfPresent('$path-shm', '$path$evidenceSuffix-shm');
      await staged.rename(path);
      return true;
    } catch (error, stackTrace) {
      Logs().w(
        'Unable to restore Matrix recovery snapshot $suffix.',
        error,
        stackTrace,
      );
      await staged.delete().catchError((_) => staged);
    }
  }
  return false;
}

Future<void> _createRecoverySnapshot(
  Database database,
  String path,
  String cipher,
) async {
  if (!await _containsStoredSession(database)) {
    return;
  }
  final primary = File('$path$_primaryRecoverySuffix');
  if (await primary.exists() &&
      DateTime.now().difference((await primary.stat()).modified) <
          _recoverySnapshotAge) {
    return;
  }

  final staged = File('$path.recovery-new');
  try {
    if (await staged.exists()) {
      await staged.delete();
    }
    final escapedPath = staged.path.replaceAll("'", "''");
    await database.execute("VACUUM INTO '$escapedPath'");
    if (!await _candidateContainsStoredSession(staged.path, cipher)) {
      throw const FormatException(
        'The new Matrix recovery snapshot failed validation.',
      );
    }
    final secondary = File('$path$_secondaryRecoverySuffix');
    if (await secondary.exists()) {
      await secondary.delete();
    }
    if (await primary.exists()) {
      await primary.rename(secondary.path);
    }
    await staged.rename(primary.path);
  } catch (error, stackTrace) {
    Logs().w(
      'Unable to refresh the Matrix recovery snapshot.',
      error,
      stackTrace,
    );
    await staged.delete().catchError((_) => staged);
  }
}

Future<void> _preserveFailedDatabase(String path) async {
  final timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;
  for (final suffix in const ['', '-wal', '-shm']) {
    final source = File('$path$suffix');
    if (await source.exists()) {
      await source
          .copy('$path.failed-open-$timestamp$suffix')
          .catchError((_) => source);
    }
  }
}

Future<void> _moveIfPresent(String sourcePath, String destinationPath) async {
  final source = File(sourcePath);
  if (await source.exists()) {
    await source.rename(destinationPath);
  }
}

Future<bool> _candidateContainsStoredSession(
  String path,
  String cipher,
) async {
  Database? candidate;
  try {
    candidate = await _openEncryptedDatabase(
      path,
      cipher,
      reliabilityPragmas: false,
    );
    return await _databaseIsHealthy(candidate) &&
        await _containsStoredSession(candidate);
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
