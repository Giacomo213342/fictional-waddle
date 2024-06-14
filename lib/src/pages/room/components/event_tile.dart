import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/is_display_event_extension.dart';
import '../room.dart';
import 'event/m_room_message.dart';
import 'event/m_room_state.dart';

class EventTile extends StatelessWidget {
  const EventTile({
    super.key,
    required this.event,
    this.previousEvent,
    this.nextEvent,
    required this.room,
    required this.controller,
    required this.timeline,
  });

  final Event event;
  final Timeline timeline;
  final Event? previousEvent;
  final Event? nextEvent;
  final Room room;
  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    if (!event.isDisplayEvent) {
      return const SizedBox();
    }
    switch (event.type) {
      case EventTypes.Reaction:
      case EventTypes.Redaction:
        return const SizedBox();
      case EventTypes.Sticker:
      case EventTypes.Message:
        return RoomMessage(
          event: event,
          timeline: timeline,
          previousEvent: previousEvent,
          nextEvent: nextEvent,
        );
      case EventTypes.RoomCreate:
      case EventTypes.RoomPowerLevels:
      case EventTypes.RoomJoinRules:
      case EventTypes.HistoryVisibility:
      case EventTypes.GuestAccess:
      case EventTypes.Encryption:
      case EventTypes.RoomMember:
        return RoomState(event: event);
      default:
        return Text(event.type);
    }
  }
}
