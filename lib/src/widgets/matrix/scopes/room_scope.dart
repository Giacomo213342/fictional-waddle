import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class RoomScope extends InheritedWidget {
  const RoomScope({
    super.key,
    required this.room,
    required super.child,
  });

  factory RoomScope.of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RoomScope>()!;

  static RoomScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RoomScope>();

  final Room room;

  @override
  bool updateShouldNotify(covariant RoomScope oldWidget) =>
      room.id != oldWidget.room.id ||
      room.membership != oldWidget.room.membership ||
      room.summary != oldWidget.room.summary ||
      room.directChatMatrixID != oldWidget.room.directChatMatrixID ||
      room.topic != oldWidget.room.topic ||
      room.avatar != oldWidget.room.avatar ||
      room.lastEvent?.eventId != oldWidget.room.lastEvent?.eventId;
}
