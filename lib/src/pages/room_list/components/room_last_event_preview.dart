import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../utils/matrix/room_last_event_loader.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/event_scope.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import 'plain_event_preview_text.dart';

class RoomLastEventPreview extends StatelessWidget {
  const RoomLastEventPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: RoomLastEventLoader.revisionFor(
        RoomScope.of(context).room,
      ),
      builder: (context, _, __) => RoomBuilder(
        builder: (context, snapshot) {
          final room = snapshot.data ?? RoomScope.of(context).room;
          return FutureBuilder(
            future: RoomLastEventLoader.load(room),
            initialData: room.lastEvent,
            builder: (context, lastEventSnapshot) {
              final lastEvent = lastEventSnapshot.data ?? room.lastEvent;
              if (lastEvent == null) {
                return const SizedBox();
              }
              if (lastEvent.type == EventTypes.Encrypted) {
                return const Text(
                  'Encrypted message',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                );
              }
              Widget preview = EventScope(
                event: lastEvent,
                child: const PlainEventPreviewText(),
              );

              if (room.isUnread) {
                preview = DefaultTextStyle.merge(
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  child: preview,
                );
              }

              return preview;
            },
          );
        },
      ),
    );
  }
}
