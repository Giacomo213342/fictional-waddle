import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../widgets/matrix/reaction_chip.dart';

class ReactionRow extends StatelessWidget {
  const ReactionRow({super.key, required this.event, required this.timeline});

  final Event event;
  final Timeline timeline;

  @override
  Widget build(BuildContext context) {
    final reactionEvents = event
        .aggregatedEvents(timeline, RelationshipTypes.reaction)
        .map((event) => event.reactionContent)
        .toSet();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: reactionEvents.map((e) => ReactionChip(content: e)).toList(),
      ),
    );
  }
}

extension on Event {
  String get reactionContent {
    return (content.tryGetMap<String, Object?>(
          'm.relates_to',
        )?['key'] as String?) ??
        text;
  }
}
