import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path_provider/path_provider.dart';

/// Serializes Matrix database ownership across foreground and headless Dart
/// isolates, including multiple Flutter engines in the same Android process.
class MatrixStoreLease {
  MatrixStoreLease._(this._lockFile, this._token) {
    _heartbeat = Timer.periodic(
      const Duration(seconds: 30),
      (_) => unawaited(_refreshHeartbeat()),
    );
  }

  static const _retryDelay = Duration(milliseconds: 40);
  static const _maximumLeaseAge = Duration(minutes: 3);

  final File _lockFile;
  final String _token;
  late final Timer _heartbeat;
  bool _released = false;

  static Future<MatrixStoreLease> acquire() async {
    final directory = await getApplicationSupportDirectory();
    return acquireFile(File('${directory.path}/matrix-store.lock'));
  }

  static Future<MatrixStoreLease> acquireFile(File lockFile) async {
    final token = _newToken();
    while (true) {
      var created = false;
      try {
        await lockFile.create(exclusive: true);
        created = true;
        await lockFile.writeAsString(
          jsonEncode({
            'pid': pid,
            'token': token,
            'createdAt': DateTime.now().toUtc().toIso8601String(),
          }),
          flush: true,
        );
        return MatrixStoreLease._(lockFile, token);
      } on FileSystemException {
        if (created) {
          await lockFile.delete().catchError((_) => lockFile);
          await Future<void>.delayed(_retryDelay);
          continue;
        }
        if (await _recoverAbandonedLease(lockFile)) {
          continue;
        }
        await Future<void>.delayed(_retryDelay);
      }
    }
  }

  static String _newToken() {
    final random = Random.secure();
    return '$pid-${DateTime.now().microsecondsSinceEpoch}-'
        '${random.nextInt(1 << 32)}';
  }

  static Future<bool> _recoverAbandonedLease(File lockFile) async {
    try {
      final stat = await lockFile.stat();
      if (stat.type == FileSystemEntityType.notFound) {
        return true;
      }
      final data = jsonDecode(await lockFile.readAsString());
      final ownerPid = data is Map ? data['pid'] : null;
      final ownerAlive = ownerPid is int &&
          ownerPid > 0 &&
          await Directory('/proc/$ownerPid').exists();
      final leaseExpired =
          DateTime.now().difference(stat.modified) > _maximumLeaseAge;
      if (ownerAlive && !leaseExpired) {
        return false;
      }

      final evidence = File(
        '${lockFile.path}.abandoned-'
        '${DateTime.now().toUtc().microsecondsSinceEpoch}',
      );
      await lockFile.rename(evidence.path);
      return true;
    } on FileSystemException {
      return !await lockFile.exists();
    } on FormatException {
      final stat = await lockFile.stat();
      return DateTime.now().difference(stat.modified) > _maximumLeaseAge &&
          await _renameMalformedLease(lockFile);
    }
  }

  static Future<bool> _renameMalformedLease(File lockFile) async {
    try {
      await lockFile.rename(
        '${lockFile.path}.malformed-'
        '${DateTime.now().toUtc().microsecondsSinceEpoch}',
      );
      return true;
    } on FileSystemException {
      return false;
    }
  }

  Future<void> _refreshHeartbeat() async {
    if (_released) {
      return;
    }
    try {
      final data = jsonDecode(await _lockFile.readAsString());
      if (data is Map && data['token'] == _token) {
        await _lockFile.setLastModified(DateTime.now());
      }
    } on FileSystemException {
      // Release/recovery won the race with this heartbeat.
    } on FormatException {
      // Never mutate a lock whose ownership cannot be proven.
    }
  }

  Future<void> release() async {
    if (_released) {
      return;
    }
    _released = true;
    _heartbeat.cancel();
    try {
      final data = jsonDecode(await _lockFile.readAsString());
      if (data is Map && data['token'] == _token) {
        await _lockFile.delete();
      }
    } on FileSystemException {
      // The process may already have recovered an expired owner.
    } on FormatException {
      // Never delete a lock whose ownership cannot be proven.
    }
  }
}
