import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room_list.dart';

class RoomListTile extends StatelessWidget {
  const RoomListTile(this.controller, {super.key, required this.room});

  final Room room;
  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(room.getLocalizedDisplayname()),
    );
  }
}
