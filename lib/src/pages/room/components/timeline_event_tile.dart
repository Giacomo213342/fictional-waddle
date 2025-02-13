import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/is_display_event_extension.dart';
import '../../../widgets/matrix/scopes/event_scope.dart';
import '../../../widgets/matrix/scopes/timeline_scope.dart';
import 'event/event_fallback_text.dart';
import 'event/m_room_message.dart';
import 'event/m_room_state.dart';

class TimelineEventTile extends StatelessWidget {
  const TimelineEventTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scope = EventScope.of(context);
    final event =
        scope.event.getDisplayEvent(TimelineScope.of(context).timeline);

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
        EventTypes.SpaceChild || EventTypes.SpaceParent => const RoomState(),
        _ => const EventFallbackText(),
      },
    );
  }
}
