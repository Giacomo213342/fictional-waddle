import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../../../widgets/dynamic_context_menu.dart';
import '../../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../../widgets/matrix/room_display_name_text.dart';
import '../../../widgets/matrix/scopes/matrix_scope.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import '../../room/room.dart';
import '../../room_details/room_details.dart';
import '../../user_page/user_page.dart';
import 'room_last_event_preview.dart';
import 'room_list_trailing.dart';

typedef ClientifyLocationCallback = String Function(String location);

class RoomListTile extends StatelessWidget {
  const RoomListTile({
    super.key,
    this.clientifyLocationCallback,
    this.onActivate,
  });

  final ClientifyLocationCallback? clientifyLocationCallback;
  final VoidCallback? onActivate;

  @override
  Widget build(BuildContext context) {
    final room = RoomScope.of(context).room;
    String location = RoomPage.makeRouteName(room.id);
    final path = clientifyLocationCallback?.call(location) ??
        context.clientifyLocation(location);

    return DynamicContextMenu(
      itemBuilder: () => _buildContextMenu(context, room),
      onTap: () {
        onActivate?.call();
        context.push(path);
      },
      child: ListTile(
        key: ValueKey(room.lastEvent),
        visualDensity: VisualDensity.compact,
        leading: RoomAvatar(
          key: ValueKey(room.id),
          room: room,
          dimension: 36,
        ),
        title: const RoomDisplayNameText(),
        subtitle: const RoomLastEventPreview(),
        trailing: const RoomListTrailing(),
      ),
    );
  }

  List<ContextMenuItem> _buildContextMenu(BuildContext context, Room room) {
    return [
      if (room.membership == Membership.invite)
        ContextMenuItem(
          icon: Icons.check,
          label: AppLocalizations.of(context).joinRoom,
          onPressed: room.join,
        ),
      if (room.isDirectChat)
        ContextMenuItem(
          icon: Icons.person,
          label: AppLocalizations.of(context).userDetails,
          onPressed: () => _userDetails(context, room),
        )
      else
        ContextMenuItem(
          icon: Icons.list,
          label: AppLocalizations.of(context).roomDetails,
          onPressed: () => _roomDetails(context, room),
        ),
      ContextMenuItem(
        icon: Icons.favorite,
        label: room.isFavourite
            ? AppLocalizations.of(context).favoriteRemove
            : AppLocalizations.of(context).favoriteAdd,
        onPressed: () => _toggleFavorite(room),
      ),
      ContextMenuItem(
        icon: Icons.circle_notifications,
        label: room.isUnread
            ? AppLocalizations.of(context).markRead
            : AppLocalizations.of(context).markUnread,
        onPressed: () => _toggleUnread(room),
      ),
      ContextMenuItem(
        icon: Icons.notifications_off,
        label: true
            ? AppLocalizations.of(context).markMute
            // ignore: dead_code
            : AppLocalizations.of(context).markUnmute,
        onPressed: () => _toggleMute(room),
      ),
      if (room.canonicalAlias.isNotEmpty)
        ContextMenuItem(
          icon: Icons.link,
          label: AppLocalizations.of(context).copyRoomAddress,
          onPressed: () => _copyRoomAddress(room),
        ),
      ContextMenuItem(
        icon: Icons.delete_forever,
        label: AppLocalizations.of(context).leaveRoom,
        onPressed: () => _leaveRoom(context, room),
        isDestructiveAction: true,
      ),
    ];
  }

  Future<void> _toggleFavorite(Room room) =>
      room.setFavourite(!room.isFavourite);

  Future<void> _toggleUnread(Room room) => room.markUnread(!room.isUnread);

  Future<void> _copyRoomAddress(Room room) =>
      Clipboard.setData(ClipboardData(text: room.canonicalAlias));

  Future<void> _leaveRoom(BuildContext context, Room room) async {
    final scope = MatrixScope.captureAll(context);
    final response = await showAdaptiveDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => MatrixScope(
        scope: scope,
        child: AlertDialog.adaptive(
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
      ),
    );
    if (response != true) {
      return;
    }
    await room.leave();
  }

  Never _toggleMute(Room room) {
    throw UnimplementedError();
  }

  Future<void> _userDetails(BuildContext context, Room room) =>
      context.pushMultiClient(
        UserPage.makeRouteName(room.directChatMatrixID),
      );

  Future<void> _roomDetails(BuildContext context, Room room) =>
      context.pushMultiClient(
        RoomDetailsPage.makeRouteName(room.id),
      );
}
