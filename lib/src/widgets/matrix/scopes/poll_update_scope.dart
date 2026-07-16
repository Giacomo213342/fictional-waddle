import 'package:flutter/widgets.dart';

class PollUpdateScope extends InheritedWidget {
  const PollUpdateScope({
    super.key,
    required this.eventIds,
    required super.child,
  });

  static PollUpdateScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PollUpdateScope>()!;

  final Stream<String> eventIds;

  @override
  bool updateShouldNotify(covariant PollUpdateScope oldWidget) =>
      eventIds != oldWidget.eventIds;
}
