import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/is_display_event_extension.dart';
import '../../../utils/matrix/call_event_summary.dart';
import '../../../utils/matrix/poll_event.dart';
import '../../../utils/matrix/polycule_display_event_extension.dart';
import '../../../widgets/matrix/scopes/event_scope.dart';
import '../../../widgets/matrix/scopes/timeline_scope.dart';
import 'event/event_fallback_text.dart';
import 'event/call_event_summary_tile.dart';
import 'event/m_room_message.dart';
import 'event/m_room_state.dart';
import 'event/m_room_tombstone.dart';

class TimelineEventTile extends StatefulWidget {
  const TimelineEventTile({super.key});

  @override
  State<TimelineEventTile> createState() => _TimelineEventTileState();
}

class _TimelineEventTileState extends State<TimelineEventTile> {
  StreamSubscription<Event>? _eventSubscription;
  Stream<Event>? _eventStream;
  Event? _event;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final scopedEvent = EventScope.of(context).event;
    final stream = TimelineScope.of(context).eventChangeStream;
    // AnimatedList reuses an index's element when an edit relation is inserted
    // before it. Never retain the previous index's event in that element.
    if (!identical(_event, scopedEvent)) {
      _event = scopedEvent;
    }
    if (!identical(stream, _eventStream)) {
      _eventSubscription?.cancel();
      _eventStream = stream;
      _eventSubscription = stream.listen(_handleEventChange);
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }

  bool _isSameLogicalEvent(Event current, Event update) {
    return current.matchesEventOrTransactionId(update.eventId) ||
        current.matchesEventOrTransactionId(update.transactionId) ||
        update.matchesEventOrTransactionId(current.eventId) ||
        update.matchesEventOrTransactionId(current.transactionId);
  }

  void _handleEventChange(Event update) {
    final current = _event;
    if (!mounted || current == null || !_isSameLogicalEvent(current, update)) {
      return;
    }
    setState(() => _event = update);
  }

  @override
  Widget build(BuildContext context) {
    final timeline = TimelineScope.of(context).timeline;
    final sourceEvent = _event ?? EventScope.of(context).event;
    final resolved = sourceEvent.resolvePolyculeDisplayEvent(timeline);
    final event = resolved.event;
    final isEdited = resolved.isEdited;

    if (!event.shouldDisplayEvent) {
      return const SizedBox();
    }
    return EventScope(
      key: ValueKey(event.eventId),
      event: event,
      child: switch (event.type) {
        EventTypes.Reaction || EventTypes.Redaction => const SizedBox(),
        EventTypes.Sticker ||
        EventTypes.Message ||
        EventTypes.Encrypted =>
          RoomMessage(isEdited: isEdited),
        MatrixPollEventTypes.start ||
        MatrixPollEventTypes.unstableStart =>
          const RoomMessage(),
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
          const RoomState(),
        EventTypes.RoomCreate ||
        EventTypes.RoomTombstone =>
          const RoomTombstone(),
        EventTypes.SpaceChild || EventTypes.SpaceParent => const RoomState(),
        _ when matrixCallLifecycleKind(event.type) != null =>
          const CallEventSummaryTile(),
        _ => const EventFallbackText(),
      },
    );
  }
}
