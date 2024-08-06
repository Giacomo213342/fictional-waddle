import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/human_date.dart';
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

    final reactionEvents = event
        .aggregatedEvents(timeline, RelationshipTypes.reaction)
        .map(
          (event) =>
              (event.content.tryGetMap<String, Object?>(
                'm.relates_to',
              )?['key'] as String?) ??
              event.text,
        )
        .toSet();

    final edits =
        event.aggregatedEvents(timeline, RelationshipTypes.edit).toList();
    edits.sort(
      (a, b) => a.originServerTs.compareTo(b.originServerTs),
    );
    final editEvent = edits.lastOrNull;

    Widget? prefix;

    Widget? editNotice;
    if (editEvent != null) {
      editNotice = Tooltip(
        message: editEvent.originServerTs
                .isAfter(DateTime.now().subtract(const Duration(days: 1)))
            ? AppLocalizations.of(context).editedToday(editEvent.originServerTs)
            : AppLocalizations.of(context).editedAt(
                editEvent.originServerTs.humanShortDate(context: context),
              ),
        child: const Icon(Icons.edit),
      );
    }

    if (showOtherSenderAvatar) {
      prefix = MessageUserAvatar(
        event: event,
      );
    } else if (event.status.isError) {
      prefix = IconButton(
        tooltip: AppLocalizations.of(context).retrySending,
        onPressed: event.sendAgain,
        icon: const Icon(Icons.restart_alt),
      );
    } else if (event.status.isSending) {
      prefix = IconButton(
        tooltip: AppLocalizations.of(context).cancelSending,
        onPressed: event.cancelSend,
        icon: const Icon(Icons.cancel_rounded),
      );
    } else if (isOwnMessage) {
      prefix = editNotice;
    } else {
      prefix = null;
    }

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
              IconTheme(
                data: IconTheme.of(context).copyWith(size: 16),
                child: SelectionArea(
                  child: SizedBox.square(
                    dimension: 32,
                    child: prefix,
                  ),
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
                            child: RoomMessageContent(
                              event: event.getDisplayEvent(timeline),
                            ),
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
                      : !isOwnMessage
                          ? editNotice
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
