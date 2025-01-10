import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../../utils/matrix/matrix_state.dart';
import '../room/room.dart';
import 'room_details_view.dart';

class RoomDetailsPage extends StatefulWidget {
  const RoomDetailsPage({
    super.key,
    required this.room,
  });

  static final path = '${RoomPage.pathParameter.asGoRouterPath()}/details';

  static String makeRouteName(String roomId) {
    return '${RoomPage.makeRouteName(roomId)}/details';
  }

  final Room room;

  @override
  State<RoomDetailsPage> createState() => RoomDetailsController();
}

class RoomDetailsController extends MatrixState<RoomDetailsPage> {
  @override
  Widget build(BuildContext context) => RoomDetailsView(controller: this);

  void close() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
    context.goMultiClient(
      RoomPage.makeRouteName(widget.room.id),
    );
  }
}
