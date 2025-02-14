import 'dart:async';

import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/matrix/scopes/room_scope.dart';
import '../room_list/room_list.dart';
import 'room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  static const pathParameter = 'roomId';

  static String makeRouteName(String roomId) {
    return '${RoomListPage.routeName}/${Uri.encodeComponent(roomId)}';
  }

  @override
  State<RoomPage> createState() => RoomController();
}

class _RoomScope extends InheritedWidget {
  const _RoomScope({
    required super.child,
    required RoomController roomState,
  }) : _roomState = roomState;

  final RoomController _roomState;

  @override
  bool updateShouldNotify(_RoomScope old) =>
      _roomState.loading != old._roomState.loading;
}

class RoomController extends State<RoomPage> {
  static RoomController of(BuildContext context) {
    final _RoomScope scope =
        context.dependOnInheritedWidgetOfExactType<_RoomScope>()!;
    return scope._roomState;
  }

  bool loading = false;

  @override
  Widget build(BuildContext context) => _RoomScope(
        roomState: this,
        child: const RoomView(),
      );

  void focusBack() {
    final room = RoomScope.of(context).room;
    RoomListController.getFocusNode(room.id).requestFocus();
  }

  Future<void> knockRoom() => joinRoom();

  Future<void> joinRoom() async {
    final room = RoomScope.of(context).room;
    setState(() {
      loading = true;
    });
    try {
      await room.join();
      await room.client.waitForRoomInSync(
        room.id,
        join: true,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).youCannotJoinThisRoom,
            ),
          ),
        );
      }
    }

    setState(() {
      loading = false;
    });
  }
}
