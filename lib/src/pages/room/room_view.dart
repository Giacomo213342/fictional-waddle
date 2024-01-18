import 'package:flutter/material.dart';

import 'room.dart';

class RoomView extends StatelessWidget {
  const RoomView(this.controller, {super.key});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('RoomView'),
      ),
    );
  }
}
