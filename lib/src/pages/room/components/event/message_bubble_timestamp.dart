import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../widgets/human_date.dart';

class MessageBubbleTimestamp extends StatelessWidget {
  const MessageBubbleTimestamp({
    super.key,
    required this.event,
    this.previousEvent,
  });

  final Event event;
  final Event? previousEvent;

  @override
  Widget build(BuildContext context) {
    final previousEvent = this.previousEvent;
    if (previousEvent != null &&
        previousEvent.originServerTs
                .difference(event.originServerTs)
                .abs()
                .inMinutes <
            5) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SelectionContainer.disabled(
        child: Text(
          event.originServerTs.humanShortDate(
            context: context,
            fullLength: true,
          ),
          style: Theme.of(context).textTheme.labelSmall,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
