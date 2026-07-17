import 'dart:convert';
import 'dart:io';

import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

/// A bounded call-lifecycle journal that survives process restarts.
///
/// Callers must only pass aggregate state. SDP, ICE candidates, addresses,
/// TURN credentials/URLs, tokens, and proxy configuration are deliberately
/// outside this API.
class CallLogJournal {
  const CallLogJournal._();

  static const _fileName = 'matrix_calls.log.jsonl';
  static const _maximumBytes = 512 * 1024;
  static const _maximumVisibleEvents = 500;

  static Future<void> record(
    String message, {
    Level level = Level.info,
  }) async {
    Logs().addLogEvent(LogEvent('[Call] $message', level: level));
    try {
      final file = await _file();
      if (await file.exists() && await file.length() > _maximumBytes) {
        await file.writeAsString('');
      }
      await file.writeAsString(
        '${jsonEncode({
              'timestamp': DateTime.now().toUtc().toIso8601String(),
              'level': level.name,
              'message': message,
            })}\n',
        mode: FileMode.append,
        flush: true,
      );
    } catch (error, stackTrace) {
      Logs().w('Unable to persist call log.', error, stackTrace);
    }
  }

  static Future<List<LogEvent>> readEvents() async {
    try {
      final file = await _file();
      if (!await file.exists()) {
        return const [];
      }
      final lines = await file.readAsLines();
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

  static Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/$_fileName');
  }
}
