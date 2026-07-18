import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// A small JSON-lines store with cross-isolate locking and bounded retention.
class BoundedLogFile {
  BoundedLogFile({
    required this.fileName,
    required this.maximumBytes,
    required this.maximumEvents,
    required this.retention,
    required this.cleanupInterval,
    Future<Directory> Function()? directoryProvider,
  }) : _directoryProvider = directoryProvider ?? getApplicationSupportDirectory;

  final String fileName;
  final int maximumBytes;
  final int maximumEvents;
  final Duration retention;
  final Duration cleanupInterval;
  final Future<Directory> Function() _directoryProvider;

  DateTime? _lastCleanup;
  Future<void> _pendingOperation = Future.value();

  Future<void> append(String line) => _withLock((file) async {
        await _cleanup(file);
        await file.writeAsString(
          '$line\n',
          mode: FileMode.append,
          flush: true,
        );
      });

  Future<List<String>> readLines() => _withLock((file) async {
        if (!await file.exists()) return const [];
        await _cleanup(file, force: true);
        return file.readAsLines();
      });

  Future<void> clearExpired() => _withLock(
        (file) => _cleanup(file, force: true),
      );

  Future<T> _withLock<T>(Future<T> Function(File file) action) {
    final result = Completer<T>();
    _pendingOperation = _pendingOperation.then((_) async {
      try {
        result.complete(await _withFileLock(action));
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });
    return result.future;
  }

  Future<T> _withFileLock<T>(Future<T> Function(File file) action) async {
    final directory = await _directoryProvider();
    final file = File('${directory.path}/$fileName');
    final lock = await File('${file.path}.lock').open(mode: FileMode.append);
    await lock.lock(FileLock.exclusive);
    try {
      return await action(file);
    } finally {
      await lock.unlock();
      await lock.close();
    }
  }

  Future<void> _cleanup(File file, {bool force = false}) async {
    if (!await file.exists()) return;
    final now = DateTime.now().toUtc();
    final oversized = await file.length() > maximumBytes;
    final lastCleanup = _lastCleanup;
    if (!force &&
        !oversized &&
        lastCleanup != null &&
        now.difference(lastCleanup) < cleanupInterval) {
      return;
    }

    final cutoff = now.subtract(retention);
    final lines = await file.readAsLines();
    final retained = lines.where((line) {
      try {
        final data = jsonDecode(line);
        if (data is! Map || data['timestamp'] is! String) return false;
        return !DateTime.parse(data['timestamp'] as String).isBefore(cutoff);
      } catch (_) {
        return false;
      }
    }).toList();
    final bounded = retained.length <= maximumEvents
        ? retained
        : retained.sublist(retained.length - maximumEvents);
    if (bounded.length != lines.length || oversized) {
      await file.writeAsString(
        bounded.isEmpty ? '' : '${bounded.join('\n')}\n',
        flush: true,
      );
    }
    _lastCleanup = now;
  }
}
