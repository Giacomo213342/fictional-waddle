import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class RoomScope extends InheritedWidget {
  const RoomScope({
    super.key,
    required this.room,
    required super.child,
  });

  static RoomScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<RoomScope>()!;
    return scope;
  }

  final Room room;

  @override
  bool updateShouldNotify(covariant RoomScope oldWidget) =>
      room.id != oldWidget.room.id;
}
