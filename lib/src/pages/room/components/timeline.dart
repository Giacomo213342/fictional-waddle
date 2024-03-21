import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room.dart';
import 'event_tile.dart';

class TimelineView extends StatelessWidget {
  const TimelineView({
    super.key,
    required this.controller,
    required this.room,
    required this.timeline,
    required this.listKey,
  });

  final RoomController controller;
  final Room room;
  final Timeline timeline;
  final GlobalKey<AnimatedListState> listKey;

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: listKey,
      reverse: true,
      initialItemCount: timeline.events.length,
      itemBuilder: (context, index, animation) => EventTile(
        event: timeline.events[index].getDisplayEvent(timeline),
        room: room,
        controller: controller,
      ),
    );
  }
}
