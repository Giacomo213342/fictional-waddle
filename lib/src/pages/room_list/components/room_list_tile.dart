import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../router/extensions/go_router_path_extension.dart';
import '../../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../room/room.dart';
import '../room_list.dart';
import 'room_list_trailing.dart';

class RoomListTile extends StatefulWidget {
  const RoomListTile(this.controller, {super.key, required this.room});

  final Room room;
  final RoomListController controller;

  @override
  State<RoomListTile> createState() => RoomListTileState();
}

class RoomListTileState extends State<RoomListTile> {
  Room? updatedRoom;

  // this is a bit more efficient than always iterating over the room list
  Room get room => updatedRoom ?? widget.room;

  @override
  Widget build(BuildContext context) {
    final path = RoomPage.makeRouteName(room.id);
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // open the room on arrow press
        const SingleActivator(LogicalKeyboardKey.arrowRight): () =>
            context.go(path),
      },
      child: Link(
        uri: Uri.parse(path),
        builder: (context, followLink) {
          final lastEvent = room.lastEvent;
          return ListTile(
            visualDensity: VisualDensity.compact,
            // make the tle keyboard focusable by request
            focusNode: RoomListController.getFocusNode(room.id),
            onTap: () => context.go(path),
            leading: RoomAvatar(
              key: ValueKey(room.id),
              room: room,
              dimension: 36,
            ),
            title: Text(
              room.getLocalizedDisplayname(),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: lastEvent == null
                ? null
                : Text(
                    lastEvent.calcLocalizedBodyFallback(
                      const MatrixDefaultLocalizations(),
                      hideReply: true,
                      hideEdit: true,
                      withSenderNamePrefix: true,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
            trailing: RoomListTrailing(room: room),
          );
        },
      ),
    );
  }

  void rebuildRoomData() {
    final newRoom = widget.controller.client.rooms.singleWhere(
      (room) => room.id == widget.room.id,
    );

    setState(() {
      updatedRoom = newRoom;
    });
  }
}
