import 'package:flutter/widgets.dart';

typedef TimelineEventNavigationCallback = Future<void> Function(String eventId);

class TimelineNavigationScope extends InheritedWidget {
  const TimelineNavigationScope({
    super.key,
    required this.onNavigate,
    required super.child,
  });

  final TimelineEventNavigationCallback onNavigate;

  static TimelineNavigationScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<TimelineNavigationScope>()!;

  @override
  bool updateShouldNotify(TimelineNavigationScope oldWidget) =>
      onNavigate != oldWidget.onNavigate;
}
