import 'dart:async';

import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';
import 'package:sentry/sentry.dart';

import 'polycule_http_client/polycule_http_client.dart';

class ErrorLogger {
  factory ErrorLogger() {
    return _instance;
  }

  ErrorLogger._();

  final initializer = Completer<void>();

  final _errorStreamController =
      StreamController<(Object?, StackTrace?)>.broadcast();

  static const _defaultDSN =
      'https://glet_5aa7a776f705926a2b4ba172ea060efe@observe.gitlab.com:443/errortracking/api/v1/projects/53926201';

  static final _instance = ErrorLogger._();

  bool sentryEnabled = false;

  Stream<(Object?, StackTrace?)> get errorStream =>
      _errorStreamController.stream;

  Future<void> captureStackTrace(Object? e, [StackTrace? s]) async {
    Level level = Level.error;
    // handle acceptable errors
    if (e is PlatformException ||
        e is MissingPluginException ||
        e is UnimplementedError) {
      level = Level.warning;
    }
    if (level.index <= Level.error.index) {
      _errorStreamController.add((e, s));
    }
    Logs().addLogEvent(
      LogEvent(
        'Runtime error on main thread.',
        exception: e,
        stackTrace: s,
        level: level,
      ),
    );

    await initializer.future;

    if (sentryEnabled) {
      uploadError(e, s);
    }
  }

  Future<void> uploadError(Object? e, StackTrace? s) async {
    if (!Sentry.isEnabled) {
      await _initializeSentry();
    }
    await Sentry.captureException(e, stackTrace: s);
  }

  Future<void> _initializeSentry() async {
    await Sentry.init(
      (options) {
        // only DSN, no profiling, no tracking, only informed, consented logging
        options.dsn = _defaultDSN;
        options.httpClient = PolyculeHttpClient.httpClient.value.call();
        // TODO: dirty code
        PolyculeHttpClient.httpClient.addListener(
          () => options.httpClient = PolyculeHttpClient.httpClient.value.call(),
        );
      },
    );
  }
}
