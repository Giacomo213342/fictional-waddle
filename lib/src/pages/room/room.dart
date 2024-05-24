import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../room_list/room_list.dart';
import 'room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room});

  static const pathParameter = 'roomId';

  static String makeRouteName(String roomId) {
    return '${RoomListPage.routeName}/$roomId';
  }

  final Room room;

  @override
  State<RoomPage> createState() => RoomController();
}

class RoomController extends State<RoomPage> {
  final focusNode = FocusNode();

  bool loading = false;

  final messageController = TextEditingController();

  Room get room => widget.room;

  @override
  Widget build(BuildContext context) => RoomView(this);

  void focusBack() => RoomListController.getFocusNode(room.id).requestFocus();

  Future<void> knockRoom() => joinRoom();

  Future<void> joinRoom() async {
    setState(() {
      loading = true;
    });
    try {
      await room.join();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).youCannotJoinThisRoom),
          ),
        );
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> sendMessage() async {
    final message = messageController.text;
    messageController.text = '';
    try {
      await room.sendTextEvent(message);
    } catch (_) {
      messageController.text = message;
    }
  }
}
