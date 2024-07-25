import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../widgets/matrix/reaction_chip.dart';
import '../message_user_avatar.dart';
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
    final previousMessageSameSender = previousEvent?.senderId ==
            event.senderId &&
        [EventTypes.Message, EventTypes.Sticker].contains(previousEvent?.type);
    final nextMessageSameSender = nextEvent?.senderId == event.senderId &&
        [EventTypes.Message, EventTypes.Sticker].contains(nextEvent?.type);
    final showOtherSenderAvatar = !isOwnMessage && !nextMessageSameSender;
    final showOwnAvatar = isOwnMessage && !nextMessageSameSender;
    final border = BorderSide(
      color: Theme.of(context).colorScheme.primary,
    );

    final reactionEvents =
        timeline.aggregatedEvents[event.eventId]?[RelationshipTypes.reaction]
                ?.map(
                  (event) =>
                      (event.content.tryGetMap<String, Object?>(
                        'm.relates_to',
                      )?['key'] as String?) ??
                      event.text,
                )
                .toSet() ??
            {};

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
              SelectionArea(
                child: SizedBox.square(
                  dimension: 32,
                  child: showOtherSenderAvatar
                      ? MessageUserAvatar(
                          event: event,
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
                    child: Padding(
                      padding: const EdgeInsets.all(1),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: constraints.maxWidth - 74,
                            child: RoomMessageContent(event: event),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: reactionEvents
                                  .map((e) => ReactionChip(content: e))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SelectionArea(
                child: SizedBox.square(
                  dimension: 32,
                  child: showOwnAvatar
                      ? MessageUserAvatar(
                          event: event,
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
