import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/poll_event.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../../room_list/room_list_position_tracker.dart';

class PollMessage extends StatelessWidget {
  const PollMessage({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    final timeline = TimelineScope.of(context).timeline;
    final answers = event.pollAnswers;
    final responses = <String, Event>{};
    for (final response in timeline.events) {
      if (response.isPollResponse &&
          response.pollResponseTarget == event.eventId) {
        responses.putIfAbsent(response.senderId, () => response);
      }
    }
    final counts = <String, int>{};
    for (final response in responses.values) {
      for (final selection in response.pollSelections) {
        counts[selection] = (counts[selection] ?? 0) + 1;
      }
    }
    final ownSelection = responses[event.room.client.userID]?.pollSelections;
    final totalVotes = responses.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            event.pollQuestion ?? 'Poll',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...answers.map((answer) {
            final votes = counts[answer.id] ?? 0;
            final selected = ownSelection?.contains(answer.id) ?? false;
            final fraction = totalVotes == 0 ? 0.0 : votes / totalVotes;
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: event.room.canSendDefaultMessages
                    ? () {
                        RoomListPositionTracker.markInteraction(event.room);
                        unawaited(
                          event.room.sendPollResponse(event.eventId, answer.id),
                        );
                      }
                    : null,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.primaryContainer
                        : Theme.of(context).colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(
                              selected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(answer.text)),
                            Text('$votes'),
                          ],
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(value: fraction),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
          Text(
            '$totalVotes ${totalVotes == 1 ? 'vote' : 'votes'}',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
