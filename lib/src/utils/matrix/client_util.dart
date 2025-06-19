import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_vodozemac/flutter_vodozemac.dart' as flutter_vodozemac;
import 'package:http/http.dart' hide Client;
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:mime/mime.dart';

import 'database/polycule_database_builder.dart';
import 'matrix_refresh_token_client.dart';

abstract class ClientUtil {
  const ClientUtil._();

  static Future<Client> clientConstructor(
    String name,
    BaseClient httpClient,
  ) async {
    final client = Client(
      name,
      database: await polyculeDatabaseBuilder(name),
      verificationMethods: {
        KeyVerificationMethod.numbers,
        KeyVerificationMethod.emoji,
        KeyVerificationMethod.qrShow,
        if (!kIsWeb && (Platform.isAndroid || Platform.isIOS))
          KeyVerificationMethod.qrScan,
        KeyVerificationMethod.reciprocate,
      },
      nativeImplementations: nativeImplementations,
      supportedLoginTypes: {
        AuthenticationTypes.password,
        AuthenticationTypes.sso,
      },
      onSoftLogout: handleSoftLogout,
      httpClient: httpClient,
      importantStateEvents: {
        'im.ponies.room_emotes',
      },
      enableDehydratedDevices: true,
      receiptsPublicByDefault: false,
      requestHistoryOnLimitedTimeline: true,
      customImageResizer: customImageResizer,
    );
    client.httpClient = buildRetryClient(client, httpClient);
    return client;
  }

  static Future<void> handleSoftLogout(Client client) async {
    while (true) {
      try {
        await client.refreshAccessToken();
        return;
      } on ClientException catch (e, s) {
        // keep waiting on network errors. This is likely due to
        // power savings on mobile.
        Logs().w('Error refreshing token. Retrying in 10 seconds.', e, s);
        await Future.delayed(const Duration(seconds: 10));
      }
    }
  }

  static BaseClient buildRetryClient(Client client, BaseClient httpClient) =>
      MatrixRefreshTokenClient(
        inner: FixedTimeoutHttpClient(
          httpClient,
          const Duration(seconds: 40),
        ),
        client: client,
      );

  static final nativeImplementations = kIsWeb
      ? NativeImplementationsWebWorker(Uri.parse('pkg/web_worker.dart.js'))
      : NativeImplementationsIsolate(compute, vodozemacInit: initVodozemac);

  static Future<MatrixImageFileResizedResponse?> customImageResizer(
    MatrixImageFileResizeArguments args,
  ) =>
      Future.value(
        switch (lookupMimeType(args.fileName, headerBytes: args.bytes)) {
          null || 'image/svg+xml' => null,
          _ => nativeImplementations.shrinkImage(args, retryInDummy: true),
        },
      ).catchError((e, s) {
        Logs().w('Error shrinking image ${args.fileName}.', e, s);
        return null;
      });

  static Future<void> initVodozemac() async {
    await flutter_vodozemac.init();
  }
}
