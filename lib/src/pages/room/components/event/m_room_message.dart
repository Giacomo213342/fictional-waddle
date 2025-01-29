import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../utils/matrix/same_message_bubble_extension.dart';
import '../../../../widgets/matrix/event_scope.dart';
import '../../../../widgets/matrix/timeline_scope.dart';
import 'components/message_context_menu.dart';
import 'components/message_prefix.dart';
import 'components/message_suffix.dart';
import 'components/reaction_row.dart';
import 'm_room_message_content.dart';
import 'message_bubble_timestamp.dart';
import 'quoted_event.dart';

class RoomMessage extends StatelessWidget {
  const RoomMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scope = EventScope.of(context);

    final timeline = TimelineScope.of(context).timeline;

    final event = scope.event;
    final previousEvent =
        timeline.getPreviousDisplayEvent(timeline.events.indexOf(event));
    final nextEvent =
        timeline.getNextDisplayEvent(timeline.events.indexOf(event));

    final previousMessageSameSender =
        previousEvent?.isSameMessageBubble(event) ?? false;
    final nextMessageSameSender =
        nextEvent?.isSameMessageBubble(event) ?? false;

    final border = BorderSide(
      color: Theme.of(context).colorScheme.primary,
    );

    Event? replyEventFallback;
    if (event.relationshipType == RelationshipTypes.reply) {
      replyEventFallback = timeline.events
          .where((e) => e.eventId == event.relationshipEventId)
          .singleOrNull;
    }

    return Padding(
      padding: EdgeInsets.only(
        left: 4,
        right: 4,
        top: !previousMessageSameSender ? 16 : 0,
        bottom: !nextMessageSameSender ? 16 : 0,
      ),
      child: LayoutBuilder(
        key: ValueKey(
          event.hashCode *
              (previousEvent?.hashCode ?? 1) *
              (nextEvent?.hashCode ?? 1),
        ),
        builder: (context, constraints) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              MessageBubbleTimestamp(
                event: event,
                previousEvent: previousEvent,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const MessagePrefix(),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 32),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: MessageContextMenu(
                        event: event,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              top: !previousMessageSameSender
                                  ? border
                                  : BorderSide.none,
                              bottom: !nextMessageSameSender
                                  ? border
                                  : BorderSide.none,
                              left: border,
                              right: border,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(1),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder(
                                  initialData: replyEventFallback,
                                  future: event.getReplyEvent(timeline),
                                  builder: (context, snapshot) {
                                    final replyEvent =
                                        snapshot.data ?? replyEventFallback;
                                    return AnimatedSize(
                                      duration:
                                          const Duration(milliseconds: 150),
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: constraints.maxWidth - 74,
                                        child: replyEvent == null
                                            ? null
                                            : EventScope(
                                                event:
                                                    replyEvent.getDisplayEvent(
                                                  timeline,
                                                ),
                                                child: const QuotedEvent(),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: constraints.maxWidth - 74,
                                  child: const RoomMessageContent(),
                                ),
                                ReactionRow(
                                  event: event,
                                  timeline: timeline,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const MessageSuffix(),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
