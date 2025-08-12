import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../router/extensions/go_router_path_extension.dart';
import '../../../../widgets/future_callback_builder.dart';
import '../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../room.dart';
import 'm_room_state.dart';

class RoomTombstone extends StatelessWidget {
  const RoomTombstone({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final event = EventScope.of(context).event;
    final replacementRoom = event.content['replacement_room'] as String?;
    final predecessor = event.content['predecessor'] as String?;

    String newRoomId;

    if (event.type == EventTypes.RoomCreate) {
      if (predecessor == null) {
        return const RoomState();
      }
      newRoomId = predecessor;
    } else if (event.type == EventTypes.RoomTombstone) {
      if (replacementRoom == null || replacementRoom == event.roomId) {
        return const RoomState();
      }
      newRoomId = replacementRoom;
    } else {
      return const RoomState();
    }

    return ListTile(
      title: FutureCallbackBuilder(
        builder: (context, callback, loading, cancel) => ElevatedButton.icon(
          onPressed: loading ? null : callback,
          icon: const Icon(Icons.upgrade),
          label: Text(
            event.type == EventTypes.RoomTombstone
                ? AppLocalizations.of(context).mRoomTombstoneAction
                : AppLocalizations.of(context).roomCreatePredecessorAction,
          ),
        ),
        callback: () async {
          final action = context.goMultiClient;
          if (client.rooms.any((room) => room.id == replacementRoom)) {
            action(
              RoomPage.makeRouteName(newRoomId),
            );
          } else {
            final roomId = await client.joinRoom(
              newRoomId,
              serverName: [event.senderId.domain!, event.room.id.domain!],
              via: [event.senderId.domain!, event.room.id.domain!],
            );
            await client.waitForRoomInSync(roomId);
            action(
              RoomPage.makeRouteName(roomId),
            );
          }
        },
      ),
      subtitle: Text(
        event.type == EventTypes.RoomTombstone
            ? AppLocalizations.of(context).mRoomTombstone
            : AppLocalizations.of(context).roomCreatePredecessor,
      ),
    );
  }
}
