import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room_scope.dart';

class RoomBuilder extends StatelessWidget {
  const RoomBuilder({super.key, required this.builder});

  final AsyncWidgetBuilder<Room> builder;

  @override
  Widget build(BuildContext context) {
    final room = RoomScope.of(context).room;
    return StreamBuilder<Room>(
      key: ValueKey(room.id),
      initialData: room,
      stream: room.client.onSync.stream
          .where(
            (update) => [
              ...?update.rooms?.join?.keys,
              ...?update.rooms?.leave?.keys,
              ...?update.rooms?.invite?.keys,
              ...?update.rooms?.knock?.keys,
            ].contains(room.id),
          )
          .map((update) => room.client.getRoomById(room.id) ?? room)
          .asyncMap((room) => room.loadHeroUsers().then((_) => room)),
      builder: (context, snapshot) => RoomScope(
        room: snapshot.data ?? room,
        child: builder(context, snapshot),
      ),
    );
  }
}
