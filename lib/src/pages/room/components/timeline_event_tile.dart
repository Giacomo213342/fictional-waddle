import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/did_change_event.dart';
import '../../../utils/matrix/is_display_event_extension.dart';
import '../room.dart';
import 'event/m_room_message.dart';
import 'event/m_room_state.dart';

class TimelineEventTile extends StatefulWidget {
  const TimelineEventTile({
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
  State<TimelineEventTile> createState() => TimelineEventTileState();
}

class TimelineEventTileState extends State<TimelineEventTile>
    with TickerProviderStateMixin<TimelineEventTile> {
  Event? event;
  Event? previousEvent;
  Event? nextEvent;

  @override
  void initState() {
    event = widget.event;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = this.event ?? widget.event;
    final previousEvent = this.previousEvent ?? widget.previousEvent;
    final nextEvent = this.nextEvent ?? widget.nextEvent;

    if (!event.shouldDisplayEvent) {
      return const SizedBox();
    }

    return switch (event.type) {
      EventTypes.Reaction || EventTypes.Redaction => const SizedBox(),
      EventTypes.Sticker ||
      EventTypes.Message ||
      EventTypes.Encrypted =>
        RoomMessage(
          event: event,
          timeline: widget.timeline,
          previousEvent: previousEvent,
          nextEvent: nextEvent,
        ),
      EventTypes.RoomCreate ||
      EventTypes.RoomPowerLevels ||
      EventTypes.RoomJoinRules ||
      EventTypes.HistoryVisibility ||
      EventTypes.GuestAccess ||
      EventTypes.Encryption ||
      EventTypes.RoomName ||
      EventTypes.RoomTopic ||
      EventTypes.RoomAvatar ||
      EventTypes.RoomAliases ||
      EventTypes.RoomCanonicalAlias ||
      EventTypes.RoomMember =>
        RoomState(event: event),
      _ => Text(
          event.calcLocalizedBodyFallback(const MatrixDefaultLocalizations()),
        ),
    };
  }

  @override
  void didUpdateWidget(covariant TimelineEventTile oldWidget) {
    if (widget.event.didChange(oldWidget.event)) {
      updateEvent();
    }

    final oldPrevious = oldWidget.previousEvent;
    final previous = widget.previousEvent;
    if (oldPrevious != null && previous != null) {
      if (previous.didChange(oldPrevious)) {
        updateEvent();
      }
    } else if (oldPrevious == null || previous == null) {
      updateEvent();
    }

    final oldNext = oldWidget.nextEvent;
    final next = widget.nextEvent;
    if (oldNext != null && next != null) {
      if (next.didChange(oldNext)) {
        updateEvent();
      }
    } else if (oldNext == null || next == null) {
      updateEvent();
    }

    super.didUpdateWidget(oldWidget);
  }

  void updateEvent({
    Event? event,
    Event? nextEvent,
    Event? previousEvent,
  }) {
    setState(() {
      if (event != null) {
        this.event = event;
      }
      if (previousEvent != null) {
        this.previousEvent = previousEvent;
      }
      if (nextEvent != null) {
        this.nextEvent = nextEvent;
      }
    });
  }
}
