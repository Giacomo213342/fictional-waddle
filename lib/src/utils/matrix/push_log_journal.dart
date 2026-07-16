import 'dart:convert';
import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

class PushLogJournal {
  const PushLogJournal._();

  static const _fileName = 'unifiedpush.log.jsonl';
  static const _maximumBytes = 512 * 1024;
  static const _maximumVisibleEvents = 500;

  static Future<void> record(
    String message, {
    Level level = Level.info,
    Object? error,
    StackTrace? stackTrace,
  }) async {
    Logs().addLogEvent(
      LogEvent(
        '[UnifiedPush] $message',
        exception: error,
        stackTrace: stackTrace,
        level: level,
      ),
    );
    try {
      final file = await _file();
      if (await file.exists() && await file.length() > _maximumBytes) {
        await file.writeAsString('');
      }
      final entry = jsonEncode({
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'level': level.name,
        'message': message,
        if (error != null) 'error': error.toString(),
        if (stackTrace != null) 'stackTrace': stackTrace.toString(),
      });
      await file.writeAsString('$entry\n', mode: FileMode.append, flush: true);
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
      final file = await _file();
      if (!await file.exists()) return const [];
      final lines = await file.readAsLines();
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

  static Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }
}
