import 'package:flutter/material.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../room/room.dart';
import 'room_details_view.dart';

class RoomDetailsPage extends StatelessWidget {
  const RoomDetailsPage({
    super.key,
  });

  static final path = '${RoomPage.pathParameter.asGoRouterPath()}/details';

  static String makeRouteName(String roomId) {
    return '${RoomPage.makeRouteName(roomId)}/details';
  }

  @override
  Widget build(BuildContext context) => const RoomDetailsView();
}
