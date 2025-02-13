import 'package:flutter/material.dart';

import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/event_scope.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import 'plain_event_preview_text.dart';

class RoomLastEventPreview extends StatelessWidget {
  const RoomLastEventPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? RoomScope.of(context).room;
        final lastEvent = room.lastEvent;
        if (lastEvent == null) {
          return const SizedBox();
        }
        return EventScope(
          event: lastEvent,
          child: const PlainEventPreviewText(),
        );
      },
    );
  }
}
