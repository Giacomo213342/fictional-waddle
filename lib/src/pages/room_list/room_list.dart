import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../utils/matrix/matrix_state.dart';
import '../ssss_bootstrap/ssss_bootstrap.dart';
import 'room_list_view.dart';

class RoomListPage extends StatefulWidget {
  const RoomListPage({super.key});

  static const routeName = '/rooms';

  @override
  State<RoomListPage> createState() => RoomListController();
}

class RoomListController extends MatrixState<RoomListPage> {
  static final Map<String, FocusNode> _focusNodes = {};

  /// provides the [FocusNode] for the room list tile of the given Room [id].
  static FocusNode getFocusNode(String id) {
    FocusNode? node = _focusNodes[id];
    return node ??= _focusNodes[id] = FocusNode();
  }

  @override
  void initState() {
    _processFirstSync();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => RoomListView(this);

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _processFirstSync() async {
    // wait for all basic data to be synced
    await client.accountDataLoading;
    await client.roomsLoading;
    await client.onSync.stream.first;
    _focusFirstRoom();
    if (!mounted) {
      return;
    }
    if (client.isUnknownSession ||
        await client.encryption?.crossSigning.isCached() == false ||
        await client.encryption?.keyManager.isCached() == false) {
      if (mounted) {
        context.go(SsssBootstrapPage.routeName);
      }
    }
  }

  /// checks whether our room list contains any item and tries to focus it
  /// In case of success, it cancels the further sync listener
  void _focusFirstRoom() {
    final firstRoom = client.rooms.firstOrNull;
    if (firstRoom == null) {
      return;
    }
    final node = getFocusNode(firstRoom.id);
    if (!node.canRequestFocus) {
      return;
    }
    node.requestFocus();
  }
}
