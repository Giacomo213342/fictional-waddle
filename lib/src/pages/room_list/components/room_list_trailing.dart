import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:matrix/matrix.dart';

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
      style: TextStyle(
        fontSize: 12,
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
              Text(
                DateFormat(DateFormat.HOUR24_MINUTE)
                    .format(lastEvent.originServerTs),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.ideographic,
              children: [
                if (room.isUnreadOrInvited) const Icon(Icons.alternate_email),
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
