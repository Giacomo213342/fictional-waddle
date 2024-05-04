import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../widgets/matrix/avatar_builder/user_avatar.dart';
import '../../../../widgets/matrix/reaction_chip.dart';
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
    final isOwnMessage = event.senderId == client.userID;
    final previousMessageSameSender = previousEvent?.senderId == event.senderId;
    final nextMessageSameSender = nextEvent?.senderId == event.senderId;
    final showOtherSenderAvatar = !isOwnMessage && !previousMessageSameSender;
    final showOwnAvatar = isOwnMessage && !previousMessageSameSender;
    final border = BorderSide(
      color: Theme.of(context).colorScheme.primary,
    );

    var reactionEvents = timeline.events
        .where(
          (element) =>
              element.type == EventTypes.Reaction &&
              element.relationshipEventId == event.eventId,
        )
        .toList();

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
            children: [
              SelectionArea(
                child: SizedBox.square(
                  dimension: 32,
                  child: showOtherSenderAvatar
                      ? UserAvatar(
                          user: event.senderFromMemoryOrFallback,
                          client: client,
                          dimension: 32,
                        )
                      : null,
                ),
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
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth - 72,
                          child: RoomMessageContent(event: event),
                        ),
                        Row(
                          children: reactionEvents
                              .map((e) => ReactionChip(event: e))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SelectionArea(
                child: SizedBox.square(
                  dimension: 32,
                  child: showOwnAvatar
                      ? UserAvatar(
                          user: event.senderFromMemoryOrFallback,
                          client: client,
                          dimension: 32,
                        )
                      : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
