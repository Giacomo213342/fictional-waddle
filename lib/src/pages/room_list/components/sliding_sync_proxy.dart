import 'dart:async';

import 'package:flutter/material.dart';

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

  List<Room>? _displayedRooms;

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
    final displayedRooms = _displayedRooms ??= [...rooms];

    return AnimatedList(
      key: listKey,
      controller: controller.scrollController,
      itemBuilder: (context, index, animation) {
        final room = _displayedRooms![index];
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
      initialItemCount: displayedRooms.length,
    );
  }

  @override
  void dispose() {
    _slidingSyncListener?.cancel();
    super.dispose();
  }

  void _simulateSlidingSync(SyncUpdate syncUpdate) {
    final displayedRooms = _displayedRooms;
    final listState = listKey.currentState;
    if (listState == null || displayedRooms == null) {
      return;
    }

    final desiredRooms = RoomListController.of(context).getRegularRooms();
    final desiredIds = desiredRooms.map((room) => room.id).toSet();

    for (var index = displayedRooms.length - 1; index >= 0; index--) {
      if (!desiredIds.contains(displayedRooms[index].id)) {
        _removeRoom(listState, index);
      }
    }

    for (var index = 0; index < desiredRooms.length; index++) {
      final desiredRoom = desiredRooms[index];
      if (index < displayedRooms.length &&
          displayedRooms[index].id == desiredRoom.id) {
        displayedRooms[index] = desiredRoom;
        continue;
      }

      final oldIndex = displayedRooms.indexWhere(
        (room) => room.id == desiredRoom.id,
        index + 1,
      );
      if (oldIndex != -1) {
        _removeRoom(listState, oldIndex);
      }
      displayedRooms.insert(index, desiredRoom);
      listState.insertItem(index);
    }

    while (displayedRooms.length > desiredRooms.length) {
      _removeRoom(listState, displayedRooms.length - 1);
    }
  }

  void _startSlidingSync() {
    _slidingSyncListener = ClientScope.of(
      context,
    ).client.onSync.stream.listen(_simulateSlidingSync);
  }

  void _removeRoom(AnimatedListState listState, int index) {
    final room = _displayedRooms!.removeAt(index);
    listState.removeItem(
      index,
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
}
