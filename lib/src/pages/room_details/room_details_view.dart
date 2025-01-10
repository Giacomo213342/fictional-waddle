import 'package:flutter/material.dart';

import 'room_details.dart';

class RoomDetailsView extends StatelessWidget {
  const RoomDetailsView({super.key, required this.controller});

  final RoomDetailsController controller;

  @override
  Widget build(BuildContext context) {
    final room = controller.widget.room;

    return Scaffold(
      appBar: AppBar(
        leading: CloseButton(
          onPressed: controller.close,
        ),
        title: Text(
          room.getLocalizedDisplayname(),
        ),
      ),
      body: ListView(),
    );
  }
}
