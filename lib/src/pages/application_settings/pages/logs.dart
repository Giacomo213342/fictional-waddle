import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/fonts.dart';
import '../../../utils/matrix/push_log_journal.dart';
import '../../../utils/matrix/voip/call_log_journal.dart';
import 'logs/log_row.dart';

class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  static const routeName = 'logs';

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<LogEvent> events = [];

  Timer? _timer;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshLogs());
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refreshLogs());
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).logs),
        actions: [
          IconButton(
            onPressed: _refreshLogs,
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).reload,
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: _refreshLogs,
        child: SelectionArea(
          child: DefaultTextStyle(
            style: TextStyle(fontFamily: PolyculeFonts.notoSansMono.name),
            child: ListView.builder(
              reverse: true,
              itemCount: events.length,
              itemBuilder: (context, index) => LogRow(events[index]),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshLogs() async {
    final results = await Future.wait([
      PushLogJournal.readEvents(),
      CallLogJournal.readEvents(),
    ]);
    if (!mounted) return;
    setState(() {
      final runtimeProblems = Logs()
          .outputEvents
          .where((event) => event.level.index <= Level.warning.index);
      events = <LogEvent>[
        ...results.expand((events) => events),
        ...runtimeProblems,
      ].reversed.take(500).toList();
    });
  }
}
