import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fullscreen media can return to and highlight its timeline event', () {
    final toolbar = File(
      'lib/src/pages/room/components/event/components/attachment_toolbar.dart',
    ).readAsStringSync();
    final timeline = File(
      'lib/src/pages/room/components/membership/join.dart',
    ).readAsStringSync();

    expect(toolbar, contains('EventNavigationScope.of(context).navigate'));
    expect(toolbar, contains('Icons.chat_bubble_outline_rounded'));
    expect(toolbar, contains("tooltip: 'Show in timeline'"));
    expect(toolbar, contains('await Navigator.of(context).maybePop()'));
    expect(toolbar, contains('await widget.onNavigateToEvent(eventId)'));
    expect(timeline, contains('Scrollable.ensureVisible('));
    expect(timeline, contains('eventHighlightStreamController.add(eventId)'));
  });
}
