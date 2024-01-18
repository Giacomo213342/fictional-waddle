import 'package:flutter/material.dart';

import 'room_list.dart';

class RoomListView extends StatelessWidget {
  const RoomListView(this.controller, {super.key});
  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('RoomListView'),
      ),
    );
  }
}
