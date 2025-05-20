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

Future<MatrixSdkDatabase> polyculeDatabaseBuilder(
  String clientName,
) async {
  if (kIsWeb) {
    unawaited(persistStorage());
    final factory = createIdbFactory();
    return MatrixSdkDatabase.init(
      clientName,
      idbFactory: factory,
    );
  }

  final cipher = await getDatabaseCipher();

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

  // fix dlopen for old Android
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

  // build a DB factory that supports SQLCipher
  databaseFactory = createDatabaseFactoryFfi(
    ffiInit: SQfLiteEncryptionHelper.ffiInit,
  );

  // initialize the encryption helper
  final helper = SQfLiteEncryptionHelper(
    factory: databaseFactory,
    path: databasePath,
    cipher: cipher,
  );

  Database database;

  // check whether the database is encrypted ad in case not encrypt it
  try {
    await helper.ensureDatabaseFileEncrypted();

    database = await databaseFactory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: 1,
        // most important : apply encryption when opening the DB
        onConfigure: helper.applyPragmaKey,
      ),
    );
  } catch (e, s) {
    final file = File(databasePath);
    if (await file.exists()) {
      await file.copy('$databasePath.broken');
      Logs()
          .wtf('Copied broken DB state for backup. Now reinitializing.', e, s);
    }
    await databaseFactory.deleteDatabase(databasePath).catchError((_) {});

    rethrow;
  }

  return MatrixSdkDatabase.init(
    clientName,
    database: database,
    maxFileSize: 1024 * 1024 * 10,
    fileStorageLocation: fileStorageLocation,
    deleteFilesAfterDuration: const Duration(days: 30),
  );
}
