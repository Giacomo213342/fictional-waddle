import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class TimelineScope extends InheritedWidget {
  const TimelineScope({
    super.key,
    required this.timeline,
    required this.eventChangeStream,
    required super.child,
  });

  static TimelineScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TimelineScope>()!;
    return scope;
  }

  final Timeline timeline;
  final Stream<Event> eventChangeStream;

  @override
  bool updateShouldNotify(covariant TimelineScope oldWidget) =>
      timeline.room.id != oldWidget.timeline.room.id;
}
