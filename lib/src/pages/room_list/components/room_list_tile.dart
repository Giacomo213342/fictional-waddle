import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:collection/collection.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/link.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../widgets/dynamic_context_menu.dart';
import '../../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../room/room.dart';
import '../../user_page/user_page.dart';
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
          return RoomBuilder(
            room: room,
            builder: (context, snapshot) {
              final room = snapshot.data ?? this.room;
              return DynamicContextMenu(
                itemBuilder: _buildContextMenu,
                // make the tle keyboard focusable by request
                focusNode: RoomListController.getFocusNode(room.id),
                onTap: followLink == null
                    ? null
                    : () {
                        widget.onActivate?.call();
                        followLink.call();
                      },
                child: ListTile(
                  visualDensity: VisualDensity.compact,
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
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<ContextMenuItem> _buildContextMenu() {
    return [
      if (room.membership == Membership.invite)
        ContextMenuItem(
          icon: Icons.check,
          label: AppLocalizations.of(context).joinRoom,
          onPressed: _join,
        ),
      if (room.isDirectChat)
        ContextMenuItem(
          icon: Icons.person,
          label: AppLocalizations.of(context).userDetails,
          onPressed: _userDetails,
        ),
      ContextMenuItem(
        icon: Icons.favorite,
        label: room.isFavourite
            ? AppLocalizations.of(context).favoriteRemove
            : AppLocalizations.of(context).favoriteAdd,
        onPressed: _toggleFavorite,
      ),
      ContextMenuItem(
        icon: Icons.circle_notifications,
        label: room.isUnread
            ? AppLocalizations.of(context).markRead
            : AppLocalizations.of(context).markUnread,
        onPressed: _toggleUnread,
      ),
      ContextMenuItem(
        icon: Icons.notifications_off,
        label: true
            ? AppLocalizations.of(context).markMute
            // ignore: dead_code
            : AppLocalizations.of(context).markUnmute,
        onPressed: _toggleMute,
      ),
      if (room.canonicalAlias.isNotEmpty)
        ContextMenuItem(
          icon: Icons.link,
          label: AppLocalizations.of(context).copyRoomAddress,
          onPressed: _copyRoomAddress,
        ),
      ContextMenuItem(
        icon: Icons.delete_forever,
        label: AppLocalizations.of(context).leaveRoom,
        onPressed: _leaveRoom,
      ),
    ];
  }

  void rebuildRoomData() {
    final newRoom = widget.controller.client.rooms.singleWhereOrNull(
      (room) => room.id == widget.room.id,
    );

    setState(() {
      updatedRoom = newRoom;
    });
  }

  Future<void> _toggleFavorite() => room.setFavourite(!room.isFavourite);

  Future<void> _toggleUnread() => room.markUnread(!room.isUnread);

  Future<void> _join() => room.join();

  Future<void> _copyRoomAddress() =>
      Clipboard.setData(ClipboardData(text: room.canonicalAlias));

  Future<void> _leaveRoom() async {
    final response = await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(AppLocalizations.of(context).leaveRoom),
        content: Text(
          AppLocalizations.of(context).leaveRoomLong(
            room.getLocalizedDisplayname(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).leaveRoom),
          ),
        ],
      ),
    );
    if (response != true) {
      return;
    }
    await room.leave();
  }

  Never _toggleMute() {
    throw UnimplementedError();
  }

  Future<void> _userDetails() => context.pushMultiClient(
        UserPage.makeRouteName(room.directChatMatrixID),
      );
}
