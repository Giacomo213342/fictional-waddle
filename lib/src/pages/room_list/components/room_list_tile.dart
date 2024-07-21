import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../router/extensions/go_router_path_extension.dart';
import '../../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../room/room.dart';
import '../room_list.dart';
import 'room_list_trailing.dart';

typedef ClientifyLocationCallback = String Function(String location);

class RoomListTile extends StatefulWidget {
  const RoomListTile(
    this.controller, {
    super.key,
    required this.room,
    this.clientifyLocationCallback,
    this.onActivate,
  });

  final Room room;
  final RoomListController controller;
  final ClientifyLocationCallback? clientifyLocationCallback;
  final VoidCallback? onActivate;

  @override
  State<RoomListTile> createState() => RoomListTileState();
}

class RoomListTileState extends State<RoomListTile> {
  Room? updatedRoom;

  // this is a bit more efficient than always iterating over the room list
  Room get room => updatedRoom ?? widget.room;

  @override
  Widget build(BuildContext context) {
    String location = RoomPage.makeRouteName(room.id);
    final path = widget.clientifyLocationCallback?.call(location) ??
        context.clientifyLocation(location);

    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // open the room on arrow press
        const SingleActivator(LogicalKeyboardKey.arrowRight): () {
          widget.onActivate?.call();
          context.go(path);
        },
      },
      child: Link(
        uri: Uri.parse(path),
        builder: (context, followLink) {
          final lastEvent = room.lastEvent;
          return ListTile(
            visualDensity: VisualDensity.compact,
            // make the tle keyboard focusable by request
            focusNode: RoomListController.getFocusNode(room.id),
            onTap: followLink == null
                ? null
                : () {
                    widget.onActivate?.call();
                    followLink.call();
                  },
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
                    lastEvent
                        .calcLocalizedBodyFallback(
                          const MatrixDefaultLocalizations(),
                          hideReply: true,
                          hideEdit: true,
                          withSenderNamePrefix: true,
                        )
                        // unicode bullet
                        .replaceAll('\n', ' \u2022 '),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
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
