import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../utils/matrix/matrix_state.dart';
import 'room_list_view.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  static const routeName = '/rooms';

  @override
  State<RoomListPage> createState() => RoomListController();
}

class RoomListController extends MatrixState<RoomListPage> {
  StreamSubscription<SyncUpdate>? _syncFocusListener;

  static final Map<String, FocusNode> _focusNodes = {};

  /// provides the [FocusNode] for the room list tile of the given Room [id].
  static FocusNode getFocusNode(String id) {
    FocusNode? node = _focusNodes[id];
    return node ??= _focusNodes[id] = FocusNode();
  }

  @override
  void initState() {
    // ensure we focus the first room available once synced
    // for keyboard navigation
    _syncFocusListener = client.onSync.stream.listen(_focusFirstRoom);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => RoomListView(this);

  @override
  void dispose() {
    _syncFocusListener?.cancel();
    super.dispose();
  }

  /// checks whether our room list contains any item and tries to focus it
  /// In case of success, it cancels the further sync listener
  void _focusFirstRoom(SyncUpdate event) {
    final firstRoom = client.rooms.firstOrNull;
    if (firstRoom == null) {
      return;
    }
    final node = getFocusNode(firstRoom.id);
    if (!node.canRequestFocus) {
      return;
    }
    node.requestFocus();
    _syncFocusListener?.cancel();
  }
}
