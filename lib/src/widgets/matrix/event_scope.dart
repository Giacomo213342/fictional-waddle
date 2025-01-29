import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class EventScope extends InheritedWidget {
  const EventScope({
    super.key,
    required this.event,
    required super.child,
  });

  static EventScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<EventScope>()!;
    return scope;
  }

  final Event event;

  @override
  bool updateShouldNotify(covariant EventScope oldWidget) =>
      event.eventId != oldWidget.event.eventId;
}
