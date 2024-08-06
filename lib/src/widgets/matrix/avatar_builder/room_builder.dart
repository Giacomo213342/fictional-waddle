import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class RoomBuilder extends StatelessWidget {
  const RoomBuilder({super.key, required this.room, required this.builder});

  final Room room;
  final AsyncWidgetBuilder<Room> builder;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Room>(
      key: ValueKey(room.id),
      initialData: room,
      stream: room.client.onRoomState.stream
          .where((update) => update.roomId == room.id)
          .map((update) => room.client.getRoomById(update.roomId) ?? room),
      builder: builder,
    );
  }
}
