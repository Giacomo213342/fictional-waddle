import 'package:flutter/widgets.dart';

typedef NavigateToEvent = Future<void> Function(String eventId);

class EventNavigationScope extends InheritedWidget {
  const EventNavigationScope({
    super.key,
    required this.navigate,
    required this.highlightEvents,
    required super.child,
  });

  static EventNavigationScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<EventNavigationScope>()!;

  final NavigateToEvent navigate;
  final Stream<String> highlightEvents;

  @override
  bool updateShouldNotify(covariant EventNavigationScope oldWidget) =>
      navigate != oldWidget.navigate ||
      highlightEvents != oldWidget.highlightEvents;
}
