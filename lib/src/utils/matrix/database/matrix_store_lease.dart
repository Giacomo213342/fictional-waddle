import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// Serializes Matrix database initialization across foreground and headless
/// Dart isolates.
///
/// Android uses a process-wide native semaphore because POSIX file locks do
/// not contend between two owners in the same process. The native plugin
/// releases permits when a FlutterEngine is destroyed, so a killed headless
/// isolate cannot strand startup. Other platforms use an in-isolate mutex.
class MatrixStoreLease {
  MatrixStoreLease._native(this._nativeToken) : _fallbackRelease = null;

  MatrixStoreLease._fallback(this._fallbackRelease) : _nativeToken = null;

  static const _channel = MethodChannel('polycule.matrix_store_lock');
  static final Map<String, Future<void>> _fallbackTails = {};

  final String? _nativeToken;
  final void Function()? _fallbackRelease;
  bool _released = false;

  static Future<MatrixStoreLease> acquire() async {
    final directory = await getApplicationSupportDirectory();
    return acquireFile(File('${directory.path}/matrix-store.lock'));
  }

  static Future<MatrixStoreLease> acquireFile(File lockFile) async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final token = await _channel.invokeMethod<String>('acquire');
        if (token == null) {
          throw PlatformException(
            code: 'NO_LOCK_TOKEN',
            message: 'Native Matrix store lock returned no token.',
          );
        }
        return MatrixStoreLease._native(token);
      } on MissingPluginException {
        // Tests and non-standard embeddings fall back to the Dart mutex.
      }
    }

    final key = lockFile.absolute.path;
    final previous = _fallbackTails[key] ?? Future<void>.value();
    final released = Completer<void>();
    _fallbackTails[key] = released.future;
    await previous;
    return MatrixStoreLease._fallback(() {
      if (!released.isCompleted) {
        released.complete();
      }
      if (identical(_fallbackTails[key], released.future)) {
        _fallbackTails.remove(key);
      }
    });
  }

  Future<void> release() async {
    if (_released) {
      return;
    }
    _released = true;
    final token = _nativeToken;
    if (token != null) {
      await _channel.invokeMethod<void>('release', {'token': token});
    } else {
      _fallbackRelease?.call();
    }
  }
}
