import 'package:flutter/material.dart';

import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/public_room_tile/public_room_tile.dart';
import '../../widgets/matrix/scopes/matrix_identifier_scope.dart';
import 'public_room.dart';

class PublicRoomView extends StatelessWidget {
  const PublicRoomView({super.key, required this.controller});

  final PublicRoomController controller;

  @override
  Widget build(BuildContext context) {
    final room = controller.room;
    final identifier = MatrixIdentifierScope.of(context).identifier;

    return Scaffold(
      appBar: AppBar(
        title: Text(identifier.primaryIdentifier),
      ),
      body: Center(
        child: room == null
            ? const AsciiProgressIndicator()
            : Card(
                child: PublicRoomTile(
                  room: room,
                  onJoin: controller.joinRoom,
                  onKnock: controller.knockRoom,
                  onPreview: controller.joinGuest,
                  action: identifier.action,
                  loading: controller.loading,
                ),
              ),
      ),
    );
  }
}
