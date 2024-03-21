import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room.dart';

class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    required this.room,
    required this.controller,
  });

  final Event event;
  final Room room;
  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return Text(event.body);
  }
}
