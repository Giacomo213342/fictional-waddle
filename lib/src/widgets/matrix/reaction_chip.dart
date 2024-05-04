import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class ReactionChip extends StatelessWidget {
  const ReactionChip({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Chip(
          labelPadding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          label: Text(
            (event.content.tryGetMap<String, Object?>(
                  'm.relates_to',
                )?['key'] as String?) ??
                event.text,
          ),
        ),
      ),
    );
  }
}
