import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/is_display_event_extension.dart';
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
    return SelectionArea(
      child: AnimatedList(
        shrinkWrap: true,
        key: listKey,
        reverse: true,
        initialItemCount: timeline.events.length + 1,
        itemBuilder: (context, index, animation) {
          if (index == timeline.events.length) {
            return LoadHistoryIndicator(
              timeline: timeline,
            );
          }

          Event? nextEvent;
          int nextEventIndex = index;
          do {
            nextEventIndex--;
            if (nextEventIndex >= 0) {
              nextEvent =
                  timeline.events[nextEventIndex].getDisplayEvent(timeline);
            } else {
              nextEvent = null;
            }
          } while (
              nextEventIndex >= 0 && !(nextEvent?.isDisplayEvent ?? false));

          Event? previousEvent;
          int previousEventIndex = index;
          do {
            previousEventIndex++;
            if (previousEventIndex < timeline.events.length) {
              previousEvent =
                  timeline.events[previousEventIndex].getDisplayEvent(timeline);
            } else {
              previousEvent = null;
            }
          } while (previousEventIndex < timeline.events.length &&
              !(previousEvent?.isDisplayEvent ?? false));

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
      ),
    );
  }
}
