import 'dart:async';

import 'package:flutter/material.dart';

import 'package:diffutil_dart/diffutil.dart';
import 'package:matrix/matrix.dart';

import '../room_list.dart';
import 'room_list_tile.dart';

class SlidingSyncProxy extends StatefulWidget {
  const SlidingSyncProxy({super.key, required this.controller});

  final RoomListController controller;

  @override
  State<SlidingSyncProxy> createState() => _SlidingSyncProxyState();
}

class _SlidingSyncProxyState extends State<SlidingSyncProxy> {
  final listKey = GlobalKey<AnimatedListState>();

  List<Room> roomsCache = [];
  Map<String, GlobalKey<RoomListTileState>> roomTileKeys = {};

  StreamSubscription<SyncUpdate>? _slidingSyncListener;

  @override
  void initState() {
    roomsCache = [...widget.controller.filteredRooms];

    _slidingSyncListener =
        widget.controller.client.onSync.stream.listen(_simulateSlidingSync);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: listKey,
      itemBuilder: (context, index, animation) {
        final room = widget.controller.filteredRooms[index];
        final key = roomTileKeys[room.id] ??= GlobalKey<RoomListTileState>();
        return SizeTransition(
          sizeFactor: animation,
          child: RoomListTile(
            key: key,
            widget.controller,
            room: room,
          ),
        );
      },
      initialItemCount: roomsCache.length,
    );
  }

  @override
  void dispose() {
    _slidingSyncListener?.cancel();
    super.dispose();
  }

  void _simulateSlidingSync(SyncUpdate syncUpdate) {
    final listState = listKey.currentState;
    if (listState == null) {
      return;
    }

    final rooms = widget.controller.filteredRooms;

    final diffResult = calculateListDiff<Room>(
      roomsCache,
      rooms,
      equalityChecker: (r1, r2) => r1.id == r2.id,
    );

    for (final update in diffResult.getUpdates()) {
      update.when(
        insert: (pos, count) {
          listState.insertAllItems(pos, count);
        },
        remove: (pos, count) {
          for (int position = pos; position < pos + count; position++) {
            final room = roomsCache[pos];
            listState.removeItem(
              pos,
              (context, animation) => SizeTransition(
                sizeFactor: animation,
                child: RoomListTile(
                  widget.controller,
                  room: room,
                ),
              ),
            );
          }
        },
        // this is a stub and will never be called
        change: (pos, payload) {
          final roomId = rooms[pos].id;
          roomTileKeys[roomId]?.currentState?.rebuildRoomData();
        },
        move: (from, to) {
          listState.removeItem(
            from,
            (context, animation) => SizeTransition(
              sizeFactor: animation,
              child: RoomListTile(
                widget.controller,
                room: roomsCache[to],
              ),
            ),
          );
          listState.insertItem(to);
        },
      );
    }

    final updatedRoomIds = {
      ...?syncUpdate.rooms?.join?.keys,
      ...?syncUpdate.rooms?.invite?.keys,
      ...?syncUpdate.rooms?.leave?.keys,
    };
    for (final roomId in updatedRoomIds) {
      roomTileKeys[roomId]?.currentState?.rebuildRoomData();
    }
    roomsCache = [...rooms];
  }
}
