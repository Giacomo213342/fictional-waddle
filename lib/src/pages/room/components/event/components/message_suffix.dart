import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../../utils/matrix/same_message_bubble_extension.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../message_user_avatar.dart';
import 'edit_tooltip.dart';

class MessageSuffix extends StatelessWidget {
  const MessageSuffix({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = TimelineScope.of(context).timeline;
    final event = EventScope.of(context).event.getDisplayEvent(timeline);
    timeline.getPreviousDisplayEvent(timeline.events.indexOf(event));
    final nextEvent =
        timeline.getNextDisplayEvent(timeline.events.indexOf(event));

    final isOwnMessage = event.senderId == event.room.client.userID;

    final edits =
        event.aggregatedEvents(timeline, RelationshipTypes.edit).toList();
    edits.sort(
      (a, b) => a.originServerTs.compareTo(b.originServerTs),
    );
    final editEvent = edits.lastOrNull;

    final nextMessageSameSender =
        nextEvent?.isSameMessageBubble(event) ?? false;
    final showOwnAvatar = isOwnMessage && !nextMessageSameSender;

    Widget? editNotice;

    if (event.redacted) {
      editNotice = const Icon(Icons.delete);
    } else if (editEvent != null) {
      editNotice = EditTooltip(editEvent: editEvent);
    }

    Widget avatar = MessageUserAvatar(
      event: event,
    );

    if (event.messageType == MessageTypes.Notice) {
      avatar = Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          const Padding(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.smart_toy),
          ),
        ],
      );
    }

    return IconTheme(
      data: IconTheme.of(context).copyWith(size: 16),
      child: SelectionArea(
        child: SizedBox.square(
          dimension: 32,
          child: showOwnAvatar
              ? avatar
              : !isOwnMessage
                  ? editNotice
                  : null,
        ),
      ),
    );
  }
}
