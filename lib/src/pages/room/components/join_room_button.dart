import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import '../room.dart';

class JoinRoomButton extends StatelessWidget {
  const JoinRoomButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = RoomController.of(context);
    return controller.loading
        ? const AsciiProgressIndicator()
        : RoomBuilder(
            builder: (context, snapshot) {
              final room = snapshot.data ?? RoomScope.of(context).room;
              return switch (room.joinRules) {
                JoinRules.public || JoinRules.invite => ElevatedButton(
                    onPressed: controller.joinRoom,
                    child: Text(
                      AppLocalizations.of(context).joinRoom,
                    ),
                  ),
                JoinRules.knock => ElevatedButton(
                    onPressed: controller.knockRoom,
                    child: Text(
                      AppLocalizations.of(context).knockRoom,
                    ),
                  ),
                _ => ElevatedButton(
                    onPressed: null,
                    child: Text(
                      AppLocalizations.of(context).youCannotJoinThisRoom,
                    ),
                  ),
              };
            },
          );
  }
}
