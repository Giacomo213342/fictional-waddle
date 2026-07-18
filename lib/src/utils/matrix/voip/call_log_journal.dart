import 'dart:convert';

import 'package:matrix/matrix.dart';

import '../../bounded_log_file.dart';

/// A bounded call-lifecycle journal that survives process restarts.
///
/// Callers must only pass aggregate state. SDP, ICE candidates, addresses,
/// TURN credentials/URLs, tokens, and proxy configuration are deliberately
/// outside this API.
class CallLogJournal {
  const CallLogJournal._();

  static const _maximumVisibleEvents = 200;
  static final _journal = BoundedLogFile(
    fileName: 'matrix_calls.log.jsonl',
    maximumBytes: 512 * 1024,
    maximumEvents: _maximumVisibleEvents,
    retention: const Duration(days: 7),
    cleanupInterval: const Duration(hours: 6),
  );

  static Future<void> record(
    String message, {
    Level level = Level.info,
    bool important = false,
  }) async {
    if (!important && level.index > Level.warning.index) return;
    try {
      await _journal.append(
        jsonEncode({
          'timestamp': DateTime.now().toUtc().toIso8601String(),
          'level': level.name,
          'message': message,
        }),
      );
    } catch (error, stackTrace) {
      Logs().w('Unable to persist call log.', error, stackTrace);
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
      Logs().w('Unable to read call log.', error, stackTrace);
      return const [];
    }
  }

  static Future<void> clearExpired() async {
    try {
      await _journal.clearExpired();
    } catch (error, stackTrace) {
      Logs().w('Unable to prune call log.', error, stackTrace);
    }
  }

  static LogEvent? _decodeEvent(String line) {
    try {
      final data = jsonDecode(line);
      if (data is! Map) {
        return null;
      }
      final timestamp = data['timestamp'];
      final message = data['message'];
      if (timestamp is! String || message is! String) {
        return null;
      }
      final level = Level.values.firstWhere(
        (item) => item.name == data['level'],
        orElse: () => Level.info,
      );
      return LogEvent('[$timestamp] [Call] $message', level: level);
    } catch (_) {
      return null;
    }
  }
}
