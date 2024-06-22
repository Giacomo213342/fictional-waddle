import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/human_date.dart';

class RoomListTrailing extends StatelessWidget {
  const RoomListTrailing({
    super.key,
    required this.room,
  });

  final Room room;

  @override
  Widget build(BuildContext context) {
    final lastEvent = room.lastEvent;
    final color = Theme.of(context).colorScheme.tertiary;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
            color: color,
          ),
      child: IconTheme(
        data: IconThemeData(
          size: 12,
          color: color,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (lastEvent != null)
              Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text(
                  lastEvent.originServerTs.humanShortDate(context: context),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                if (room.isUnreadOrInvited)
                  const Icon(Icons.fiber_manual_record),
                if (room.isFavourite) const Icon(Icons.favorite),
              ]
                  .map(
                    (e) => Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: e,
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
