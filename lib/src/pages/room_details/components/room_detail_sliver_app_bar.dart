import 'package:flutter/material.dart';

import '../../../router/extensions/go_router_path_extension.dart';
import '../../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/room_display_name_text.dart';
import '../../../widgets/matrix/room_scope.dart';
import '../../room/room.dart';

class RoomDetailSliverAppBar extends StatelessWidget {
  const RoomDetailSliverAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? RoomScope.of(context).room;
        return SliverAppBar(
          expandedHeight: room.avatar == null ? null : 256,
          leading: CloseButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
              context.goMultiClient(
                RoomPage.makeRouteName(room.id),
              );
            },
          ),
          flexibleSpace: FlexibleSpaceBar(
            title: const RoomDisplayNameText(),
            background: room.avatar == null
                ? null
                : RoomAvatar.fullScreenButton(
                    context: context,
                    room: room,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }
}
