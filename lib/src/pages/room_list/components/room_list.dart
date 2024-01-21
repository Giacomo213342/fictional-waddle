import 'package:flutter/material.dart';

import '../room_list.dart';
import 'room_list_tile.dart';

class RoomList extends StatelessWidget {
  const RoomList(this.controller, {super.key});

  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
    final rooms = controller.client.rooms;
    return ListView.builder(
      itemBuilder: (context, index) => RoomListTile(
        controller,
        room: rooms[index],
      ),
      itemCount: rooms.length,
    );
  }
}
