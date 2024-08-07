import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/same_message_bubble_extension.dart';
import 'components/message_prefix.dart';
import 'components/message_suffix.dart';
import 'components/reaction_row.dart';
import 'm_room_message_content.dart';

class RoomMessage extends StatelessWidget {
  const RoomMessage({
    super.key,
    required this.event,
    this.previousEvent,
    this.nextEvent,
    required this.timeline,
  });

  final Timeline timeline;
  final Event event;
  final Event? previousEvent;
  final Event? nextEvent;

  Client get client => event.room.client;

  @override
  Widget build(BuildContext context) {
    final nextEvent = this.nextEvent?.getDisplayEvent(timeline);
    final previousEvent = this.previousEvent?.getDisplayEvent(timeline);

    final isOwnMessage = event.senderId == client.userID;

    final previousMessageSameSender =
        previousEvent?.isSameMessageBubble(event.senderId) ?? false;
    final nextMessageSameSender =
        nextEvent?.isSameMessageBubble(event.senderId) ?? false;

    final border = BorderSide(
      color: Theme.of(context).colorScheme.primary,
    );

    final edits =
        event.aggregatedEvents(timeline, RelationshipTypes.edit).toList();
    edits.sort(
      (a, b) => a.originServerTs.compareTo(b.originServerTs),
    );
    final editEvent = edits.lastOrNull;

    return Padding(
      padding: EdgeInsets.only(
        left: 4,
        right: 4,
        top: !previousMessageSameSender ? 16 : 0,
        bottom: !nextMessageSameSender ? 16 : 0,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              MessagePrefix(
                event: event,
                editEvent: editEvent,
                isOwnMessage: isOwnMessage,
                nextMessageSameSender: nextMessageSameSender,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 32),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border(
                        top: !previousMessageSameSender
                            ? border
                            : BorderSide.none,
                        bottom:
                            !nextMessageSameSender ? border : BorderSide.none,
                        left: border,
                        right: border,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth - 74,
                            child: RoomMessageContent(
                              event: event.getDisplayEvent(timeline),
                            ),
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
              MessageSuffix(
                event: event,
                editEvent: editEvent,
                isOwnMessage: isOwnMessage,
                nextMessageSameSender: nextMessageSameSender,
              ),
            ],
          );
        },
      ),
    );
  }
}
