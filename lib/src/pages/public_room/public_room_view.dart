import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/public_room_tile/public_room_tile.dart';
import 'public_room.dart';

class PublicRoomView extends StatelessWidget {
  const PublicRoomView({super.key, required this.controller});

  final PublicRoomController controller;

  @override
  Widget build(BuildContext context) {
    final room = controller.room;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.widget.filter.genericSearchTerm ??
              AppLocalizations.of(context).appName,
        ),
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
                  action: controller.widget.action,
                  loading: controller.loading,
                ),
              ),
      ),
    );
  }
}
