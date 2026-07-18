import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:flutter_vodozemac/flutter_vodozemac.dart' as flutter_vodozemac;
import 'package:http/http.dart' hide Client;
import 'package:matrix/encryption.dart';
import 'package:matrix/matrix.dart';
import 'package:mime/mime.dart';

import 'database/polycule_database_builder.dart';
import 'matrix_auth_retry_client.dart';
import 'matrix_refresh_token_client.dart';
import 'poll_event.dart';
import 'session_refresh_retrier.dart';

abstract class ClientUtil {
  const ClientUtil._();

  static Future<Client> clientConstructor(
    String name,
    BaseClient httpClient, {
    Duration requestTimeout = const Duration(seconds: 40),
  }) async {
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
      importantStateEvents: {'im.ponies.room_emotes'},
      roomPreviewLastEvents: {
        MatrixPollEventTypes.start,
        MatrixPollEventTypes.unstableStart,
      },
      enableDehydratedDevices: true,
      receiptsPublicByDefault: true,
      requestHistoryOnLimitedTimeline: true,
      customImageResizer: customImageResizer,
    );
    client.httpClient = buildRetryClient(
      client,
      httpClient,
      requestTimeout: requestTimeout,
    );
    return client;
  }

  static Future<void> handleSoftLogout(Client client) async {
    final retrier = SessionRefreshRetrier(
      onRoundExhausted: (error, stackTrace, exhaustedRounds) {
        // Avoid flooding Application logs during long network outages.
        if (exhaustedRounds == 1 || exhaustedRounds % 10 == 0) {
          Logs().w(
            'Matrix session refresh is temporarily unavailable; keeping the '
            'session and retrying.',
            error,
            stackTrace,
          );
        }
      },
    );
    await retrier.run(client.refreshAccessToken);
  }

  static BaseClient buildRetryClient(
    Client client,
    BaseClient httpClient, {
    Duration requestTimeout = const Duration(seconds: 40),
  }) =>
      MatrixRefreshTokenClient(
        inner: MatrixAuthRetryClient(
          inner: FixedTimeoutHttpClient(httpClient, requestTimeout),
          homeserver: () => client.homeserver,
        ),
        client: client,
      );

  static final nativeImplementations = kIsWeb
      ? NativeImplementationsWebWorker(Uri.parse('pkg/web_worker.dart.js'))
      : NativeImplementationsIsolate(compute, vodozemacInit: initVodozemac);

  static Future<MatrixImageFileResizedResponse?> customImageResizer(
    MatrixImageFileResizeArguments args,
  ) =>
      Future.value(switch (lookupMimeType(
        args.fileName,
        headerBytes: args.bytes,
      )) {
        null || 'image/svg+xml' => null,
        _ => nativeImplementations.shrinkImage(
            args,
            retryInDummy: true,
          ),
      })
          .catchError((e, s) {
        Logs().w('Error shrinking image ${args.fileName}.', e, s);
        return null;
      });

  static Future<void> initVodozemac() async {
    await flutter_vodozemac.init();
  }
}
