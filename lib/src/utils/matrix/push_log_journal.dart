import 'dart:convert';

import 'package:matrix/matrix.dart';

import '../bounded_log_file.dart';

class PushLogJournal {
  const PushLogJournal._();

  static const _maximumVisibleEvents = 200;
  static final _journal = BoundedLogFile(
    fileName: 'unifiedpush.log.jsonl',
    maximumBytes: 512 * 1024,
    maximumEvents: _maximumVisibleEvents,
    retention: const Duration(days: 7),
    cleanupInterval: const Duration(hours: 6),
  );

  static Future<void> record(
    String message, {
    Level level = Level.info,
    Object? error,
    StackTrace? stackTrace,
    bool important = false,
  }) async {
    if (!important && level.index > Level.warning.index) return;
    try {
      final entry = jsonEncode({
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'level': level.name,
        'message': message,
        if (error != null) 'error': error.toString(),
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      });
      await _journal.append(entry);
    } catch (journalError, journalStackTrace) {
      Logs().w(
        'Unable to persist UnifiedPush log.',
        journalError,
        journalStackTrace,
      );
    }
  }

  static Future<List<LogEvent>> readEvents() async {
    try {
      final lines = await _journal.readLines();
      return lines.reversed
          .take(_maximumVisibleEvents)
          .map(_decodeEvent)
          .whereType<LogEvent>()
          .toList()
          .reversed
          .toList();
    } catch (error, stackTrace) {
      Logs().w('Unable to read UnifiedPush log.', error, stackTrace);
      return const [];
    }
  }

  static Future<void> clearExpired() async {
    try {
      await _journal.clearExpired();
    } catch (error, stackTrace) {
      Logs().w('Unable to prune UnifiedPush log.', error, stackTrace);
    }
  }

  static LogEvent? _decodeEvent(String line) {
    try {
      final data = jsonDecode(line);
      if (data is! Map) return null;
      final timestamp = data['timestamp'];
      final message = data['message'];
      if (timestamp is! String || message is! String) return null;
      final levelName = data['level'];
      final level = Level.values.firstWhere(
        (item) => item.name == levelName,
        orElse: () => Level.info,
      );
      final stack = data['stackTrace'];
      return LogEvent(
        '[$timestamp] [UnifiedPush] $message',
        exception: data['error'],
        stackTrace: stack is String ? StackTrace.fromString(stack) : null,
        level: level,
      );
    } catch (_) {
      return null;
    }
  }
}
