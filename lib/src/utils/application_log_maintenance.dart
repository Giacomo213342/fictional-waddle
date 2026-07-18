import 'dart:async';

import 'package:matrix/matrix.dart';

import 'matrix/push_log_journal.dart';
import 'matrix/voip/call_log_journal.dart';

/// Keeps diagnostic logs useful without letting routine SDK output accumulate.
class ApplicationLogMaintenance {
  const ApplicationLogMaintenance._();

  static const clearInterval = Duration(hours: 24);

  static Timer? _timer;

  static Future<void> start() async {
    if (_timer != null) return;
    await _clearAndPrune();
    _timer = Timer.periodic(
      clearInterval,
      (_) => unawaited(_clearAndPrune()),
    );
  }

  static Future<void> _clearAndPrune() async {
    Logs().outputEvents.clear();
    await Future.wait([
      PushLogJournal.clearExpired(),
      CallLogJournal.clearExpired(),
    ]);
  }
}
