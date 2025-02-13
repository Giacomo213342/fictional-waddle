import 'dart:async';

import 'package:flutter/material.dart';

import 'package:diffutil_dart/diffutil.dart';
import 'package:matrix/matrix.dart';

import '../../../widgets/matrix/scopes/client_scope.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import '../room_list.dart';
import 'room_list_tile.dart';

class SlidingSyncProxy extends StatefulWidget {
  const SlidingSyncProxy({super.key});

  @override
  State<SlidingSyncProxy> createState() => _SlidingSyncProxyState();
}

class _SlidingSyncProxyState extends State<SlidingSyncProxy> {
  final listKey = GlobalKey<AnimatedListState>();

  List<Room>? roomsCache;

  StreamSubscription<SyncUpdate>? _slidingSyncListener;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSlidingSync());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final controller = RoomListController.of(context);
    final rooms = controller.getRegularRooms();
    final roomsCache = this.roomsCache ??= rooms;

    return AnimatedList(
      key: listKey,
      itemBuilder: (context, index, animation) {
        final room = RoomListController.of(context).getRegularRooms()[index];
        return SizeTransition(
          key: Key(room.id),
          sizeFactor: animation,
          child: RoomScope(
            key: ValueKey(room.id),
            room: room,
            child: const RoomListTile(),
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
    final roomsCache = this.roomsCache;
    final listState = listKey.currentState;
    if (listState == null || roomsCache == null) {
      return;
    }

    final rooms = RoomListController.of(context).getRegularRooms();

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
                key: Key(room.id),
                sizeFactor: animation,
                child: RoomScope(
                  key: ValueKey(room.id),
                  room: room,
                  child: const RoomListTile(),
                ),
              ),
            );
          }
        },
        // this is a stub and will never be called
        change: (pos, payload) {},
        move: (from, to) {
          listState.removeItem(
            from,
            (context, animation) {
              final room = roomsCache[to];
              return SizeTransition(
                key: Key(room.id),
                sizeFactor: animation,
                child: RoomScope(
                  key: ValueKey(room.id),
                  room: room,
                  child: const RoomListTile(),
                ),
              );
            },
          );
          listState.insertItem(to);
        },
      );
    }
    this.roomsCache = [...rooms];
  }

  void _startSlidingSync() {
    _slidingSyncListener = ClientScope.of(context)
        .client
        .onSync
        .stream
        .listen(_simulateSlidingSync);
  }
}
