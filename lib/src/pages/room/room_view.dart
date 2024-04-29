import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/matrix/avatar_builder/room_avatar.dart';
import 'components/room_body.dart';
import 'room.dart';

class RoomView extends StatelessWidget {
  const RoomView(this.controller, {super.key});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        // navigate keyboard focus back to the room
        // list on backspace or arrow back
        const SingleActivator(LogicalKeyboardKey.backspace):
            controller.focusBack,
        const SingleActivator(LogicalKeyboardKey.arrowLeft):
            controller.focusBack,
      },
      child: Focus(
        autofocus: true,
        // the focus node ensures we can request initial keyboard focus
        focusNode: controller.focusNode,
        child: Scaffold(
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.all(2),
              child: RoomAvatar(
                room: controller.room,
                dimension: 64,
              ),
            ),
            title: Text(controller.room.getLocalizedDisplayname()),
          ),
          body: Semantics(
            hint: AppLocalizations.of(context).regionChatContents,
            child: RoomBody(
              controller: controller,
              key: ValueKey(controller.room.id),
            ),
          ),
        ),
      ),
    );
  }
}
