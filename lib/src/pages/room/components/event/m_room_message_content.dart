import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'm_room_message/m_image.dart';
import 'm_room_message/m_text.dart';

class RoomMessageContent extends StatelessWidget {
  const RoomMessageContent({super.key, required this.event});

  final Event event;

  Client get client => event.room.client;

  @override
  Widget build(BuildContext context) {
    switch (event.messageType) {
      case MessageTypes.Image:
        return ImageMessage(event: event);
      case MessageTypes.Text:
        return TextMessage(event: event);
      default:
        return Text(event.messageType);
    }
  }
}
