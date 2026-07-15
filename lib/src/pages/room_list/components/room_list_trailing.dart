import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/human_date.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';

class RoomListTrailing extends StatelessWidget {
  const RoomListTrailing({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.tertiary;
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.labelMedium!.copyWith(color: color),
      child: IconTheme(
        data: IconThemeData(size: 12, color: color),
        child: RoomBuilder(
          builder: (context, snapshot) {
            final room = snapshot.data ?? RoomScope.of(context).room;
            final lastEvent = room.lastEvent;
            return Column(
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
                  children:
                      [
                            if (room.isUnreadOrInvited)
                              const Icon(Icons.fiber_manual_record),
                            if (room.isFavourite) const Icon(Icons.favorite),
                            if (room.tags.containsKey(TagType.lowPriority))
                              const Icon(Icons.low_priority),
                            if (room.pushRuleState == PushRuleState.dontNotify)
                              const Icon(Icons.notifications_off),
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
            );
          },
        ),
      ),
    );
  }
}
