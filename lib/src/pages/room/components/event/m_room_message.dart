import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../utils/matrix/is_display_event_extension.dart';
import '../../../../utils/matrix/same_message_bubble_extension.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import 'components/message_context_menu.dart';
import 'components/message_prefix.dart';
import 'components/message_suffix.dart';
import 'components/reaction_row.dart';
import 'm_room_message_content.dart';
import 'message_bubble_timestamp.dart';
import 'quoted_event.dart';
import '../timeline/timeline_navigation_scope.dart';

class RoomMessage extends StatelessWidget {
  const RoomMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = EventScope.of(context);

    final timeline = TimelineScope.of(context).timeline;

    final event = scope.event;
    final previousEvent = timeline.getPreviousDisplayEvent(
      timeline.events.indexOf(event),
    );
    final nextEvent = timeline.getNextDisplayEvent(
      timeline.events.indexOf(event),
    );

    final previousMessageSameSender =
        previousEvent?.isSameMessageBubble(event) ?? false;
    final nextMessageSameSender =
        nextEvent?.isSameMessageBubble(event) ?? false;
    final isOwnMessage = event.senderId == event.room.client.userID;
    final showSenderName = !isOwnMessage &&
        (event.room.summary.mJoinedMemberCount ?? 0) >= 4 &&
        !previousMessageSameSender;
    final isEdited =
        event.aggregatedEvents(timeline, RelationshipTypes.edit).isNotEmpty;
    final isRead = event.isReadByEnoughPeople(timeline);

    final border = BorderSide(color: Theme.of(context).colorScheme.primary);

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
          final contentWidth = constraints.maxWidth - 74;
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
                                if (showSenderName)
                                  SizedBox(
                                    width: contentWidth,
                                    child: _MessageSenderName(event: event),
                                  ),
                                FutureBuilder(
                                  initialData: replyEventFallback,
                                  future: event.getReplyEvent(timeline),
                                  builder: (context, snapshot) {
                                    final replyEvent =
                                        snapshot.data ?? replyEventFallback;
                                    return AnimatedSize(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: SizedBox(
                                        width: contentWidth,
                                        child: replyEvent == null
                                            ? null
                                            : EventScope(
                                                event: replyEvent
                                                    .getDisplayEvent(timeline),
                                                child: QuotedEvent(
                                                  onTap: () =>
                                                      TimelineNavigationScope
                                                          .of(
                                                    context,
                                                  ).onNavigate(
                                                    replyEvent.eventId,
                                                  ),
                                                ),
                                              ),
                                      ),
                                    );
                                  },
                                ),
                                SizedBox(
                                  width: contentWidth,
                                  child: const RoomMessageContent(),
                                ),
                                ReactionRow(event: event, timeline: timeline),
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
              if (isRead || isEdited)
                Padding(
                  padding: EdgeInsets.only(
                    top: 2,
                    left: isOwnMessage ? 0 : 12,
                    right: isOwnMessage ? 12 : 0,
                    bottom: 2,
                  ),
                  child: Align(
                    alignment: isOwnMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Text(
                      isOwnMessage
                          ? [if (isRead) 'read', if (isEdited) 'e'].join(' ')
                          : 'e',
                      style: const TextStyle(color: Colors.grey, fontSize: 10),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MessageSenderName extends StatelessWidget {
  const _MessageSenderName({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: event.fetchSenderUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? event.senderFromMemoryOrFallback;
        return Padding(
          padding: const EdgeInsets.fromLTRB(8, 5, 8, 2),
          child: Text(
            user.displayName ?? user.id,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        );
      },
    );
  }
}

extension on Event {
  bool isReadByEnoughPeople(Timeline timeline) {
    if (senderId != room.client.userID) return false;

    final myIndex = timeline.events.indexOf(this);
    if (myIndex == -1) return false;

    int getReadCount(Event e) {
      int count = 0;
      final eIndex = timeline.events.indexOf(e);
      for (final entry in room.receiptState.global.otherUsers.entries) {
        if (entry.key == senderId || entry.key == room.client.userID) continue;
        final receiptEventId = entry.value.eventId;
        if (receiptEventId == e.eventId) {
          count++;
        } else {
          final receiptIndex = timeline.events.indexWhere(
            (ev) => ev.eventId == receiptEventId,
          );
          if (receiptIndex != -1 && receiptIndex <= eIndex) {
            count++;
          } else if (receiptIndex == -1 &&
              entry.value.ts >= e.originServerTs.millisecondsSinceEpoch) {
            count++;
          }
        }
      }
      return count;
    }

    final readCount = getReadCount(this);
    final memberCount = room.summary.mJoinedMemberCount ?? 2;
    final requiredReads = memberCount <= 3 ? 1 : memberCount - 1;

    if (readCount < requiredReads) return false;

    for (int i = 0; i < myIndex; i++) {
      final newerEvent = timeline.events[i];
      if (newerEvent.senderId == room.client.userID &&
          newerEvent.shouldDisplayEvent) {
        if (getReadCount(newerEvent) >= requiredReads) {
          return false;
        }
      }
    }
    return true;
  }
}
