import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/is_display_event_extension.dart';
import '../room.dart';
import 'event/m_room_message.dart';
import 'event/m_room_state.dart';

const _kPulseCurve = Curves.easeInOutBack;

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
  late AnimationController _opacityController;

  Event? event;

  @override
  void initState() {
    event = widget.event;
    _opacityController = AnimationController(
      value: 1,
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    super.initState();
  }

  @override
  void dispose() {
    _opacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = this.event ?? widget.event;
    final previousEvent = widget.previousEvent;
    final nextEvent = widget.nextEvent;

    if (!event.shouldDisplayEvent) {
      return const SizedBox();
    }

    return FadeTransition(
      opacity: _opacityController,
      child: switch (event.type) {
        EventTypes.Reaction || EventTypes.Redaction => const SizedBox(),
        EventTypes.Sticker || EventTypes.Message => RoomMessage(
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
      },
    );
  }

  @override
  void didUpdateWidget(covariant TimelineEventTile oldWidget) {
    if (oldWidget.event.attachmentMxcUrl != widget.event.attachmentMxcUrl ||
        oldWidget.event.thumbnailMxcUrl != widget.event.thumbnailMxcUrl ||
        oldWidget.event.body != widget.event.body ||
        oldWidget.event.status != widget.event.status) {
      unawaited(updateEvent());
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> updateEvent([Event? event]) async {
    setState(() {
      this.event = event;
    });
    await _opacityController.animateBack(.5, curve: _kPulseCurve);
    await _opacityController.animateTo(1, curve: _kPulseCurve);
  }
}
