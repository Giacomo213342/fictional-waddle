import 'package:flutter/material.dart';

import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/html/polycule_html_view.dart';
import '../../../widgets/matrix/room_scope.dart';

class RoomTopicView extends StatelessWidget {
  const RoomTopicView({super.key});

  @override
  Widget build(BuildContext context) {
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? RoomScope.of(context).room;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          child: SelectionArea(
            child: PolyculeHtmlView(
              html: room.topic.replaceAll('\n', r'<br />'),
              client: room.client,
              room: room,
            ),
          ),
        );
      },
    );
  }
}
