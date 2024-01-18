import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room});

  static const pathParameter = 'roomId';

  final Room room;

  @override
  State<RoomPage> createState() => RoomController();
}

class RoomController extends State<RoomPage> {
  @override
  Widget build(BuildContext context) => RoomView(this);
}
