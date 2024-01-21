import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room_list/room_list.dart';
import 'room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room});

  static const pathParameter = 'roomId';

  static String makeRouteName(String roomId) {
    return '${RoomListPage.routeName}/$roomId';
  }

  final Room room;

  @override
  State<RoomPage> createState() => RoomController();
}

class RoomController extends State<RoomPage> {
  final focusNode = FocusNode();

  Room get room => widget.room;

  @override
  Widget build(BuildContext context) => RoomView(this);

  void focusBack() => RoomListController.getFocusNode(room.id).requestFocus();
}
