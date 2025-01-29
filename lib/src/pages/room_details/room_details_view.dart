import 'package:flutter/material.dart';

import '../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../widgets/matrix/room_scope.dart';
import 'components/public_room_address_tile.dart';
import 'components/room_detail_sliver_app_bar.dart';
import 'components/room_topic_view.dart';

class RoomDetailsView extends StatelessWidget {
  const RoomDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? RoomScope.of(context).room;
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              const RoomDetailSliverAppBar(),
              SliverList.list(
                children: [
                  if (room.topic.isNotEmpty) const RoomTopicView(),
                  if (room.canonicalAlias.isNotEmpty)
                    const PublicRoomAddressTile(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
