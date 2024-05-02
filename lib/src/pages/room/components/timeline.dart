import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room.dart';
import 'event_tile.dart';
import 'load_history_indicator.dart';

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
      initialItemCount: timeline.events.length + 1,
      itemBuilder: (context, index, animation) {
        if (index == timeline.events.length) {
          return LoadHistoryIndicator(
            timeline: timeline,
          );
        }
        final nextEvent = index - 1 >= 0
            ? timeline.events[index - 1].getDisplayEvent(timeline)
            : null;

        final previousEvent = index + 1 < timeline.events.length
            ? timeline.events[index + 1].getDisplayEvent(timeline)
            : null;
        final event = timeline.events[index].getDisplayEvent(timeline);

        return EventTile(
          event: event,
          previousEvent: previousEvent,
          nextEvent: nextEvent,
          room: room,
          controller: controller,
          timeline: timeline,
        );
      },
    );
  }
}
