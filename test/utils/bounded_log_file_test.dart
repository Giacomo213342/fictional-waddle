import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/bounded_log_file.dart';

void main() {
  late Directory directory;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('polycule-log-test-');
  });

  tearDown(() async {
    await directory.delete(recursive: true);
  });

  BoundedLogFile journal({int maximumEvents = 200}) => BoundedLogFile(
        fileName: 'events.jsonl',
        maximumBytes: 512 * 1024,
        maximumEvents: maximumEvents,
        retention: const Duration(days: 7),
        cleanupInterval: const Duration(hours: 6),
        directoryProvider: () async => directory,
      );

  String entry(DateTime timestamp, int id) => jsonEncode({
        'timestamp': timestamp.toUtc().toIso8601String(),
        'id': id,
      });

  test('removes expired entries and retains recent ones', () async {
    final log = journal();
    await log
        .append(entry(DateTime.now().subtract(const Duration(days: 8)), 1));
    await log.append(entry(DateTime.now(), 2));

    final lines = await log.readLines();

    expect(lines, hasLength(1));
    expect(jsonDecode(lines.single)['id'], 2);
  });

  test('keeps only the newest configured number of events', () async {
    final log = journal(maximumEvents: 3);
    for (var id = 0; id < 5; id++) {
      await log.append(entry(DateTime.now(), id));
    }

    final ids = (await log.readLines())
        .map((line) => jsonDecode(line)['id'] as int)
        .toList();

    expect(ids, [2, 3, 4]);
  });

  test('serializes cleanup and concurrent appends without losing entries',
      () async {
    final log = journal(maximumEvents: 20);
    await Future.wait([
      for (var id = 0; id < 10; id++) log.append(entry(DateTime.now(), id)),
      log.clearExpired(),
    ]);

    final ids = (await log.readLines())
        .map((line) => jsonDecode(line)['id'] as int)
        .toSet();

    expect(ids, {for (var id = 0; id < 10; id++) id});
  });
}
