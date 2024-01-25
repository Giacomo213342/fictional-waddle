import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'cipher.dart';
import 'idb/stub.dart' if (dart.library.html) 'idb/web.dart';

import 'sqlcipher_stub.dart'
    if (dart.library.io) 'package:sqlcipher_flutter_libs/sqlcipher_flutter_libs.dart';

Future<MatrixSdkDatabase> polyculeDatabaseBuilder(Client client) async {
  if (kIsWeb) {
    await persistStorage();
    final factory = createIdbFactory();
    final db = MatrixSdkDatabase(
      client.clientName,
      idbFactory: factory,
    );
    await db.open();
    return db;
  }

  final cipher = await getDatabaseCipher();

  final fileStoragePath = await getApplicationSupportDirectory();
  final temporaryStoragePath = await getTemporaryDirectory();

  final path = '${fileStoragePath.path}/${client.clientName}.sqlite';

  // fix dlopen for old Android
  await applyWorkaroundToOpenSqlCipherOnOldAndroidVersions();

  // build a DB factory that supports SQLCipher
  final factory = createDatabaseFactoryFfi(
    ffiInit: SQfLiteEncryptionHelper.ffiInit,
  );

  // initialize the encryption helper
  final helper = SQfLiteEncryptionHelper(
    factory: factory,
    path: path,
    cipher: cipher,
  );

  Database database;

  // check whether the database is encrypted ad in case not encrypt it
  try {
    await helper.ensureDatabaseFileEncrypted();

    database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        // most important : apply encryption when opening the DB
        onConfigure: helper.applyPragmaKey,
      ),
    );
  } catch (e, s) {
    final file = File(path);
    if (await file.exists()) {
      await file.copy('$path.broken');
      Logs()
          .wtf('Copied broken DB state for backup. Now reinitializing.', e, s);
    }
    await factory.deleteDatabase(path).catchError((_) {});

    rethrow;
  }

  final db = MatrixSdkDatabase(
    client.clientName,
    database: database,
    maxFileSize: 1024 * 1024 * 10,
    fileStoragePath: temporaryStoragePath,
    deleteFilesAfterDuration: const Duration(days: 30),
  );
  await db.open();
  return db;
}
