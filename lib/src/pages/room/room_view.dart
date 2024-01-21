import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
            title: Text(controller.room.getLocalizedDisplayname()),
          ),
          body: const Center(
            child: Text('RoomView'),
          ),
        ),
      ),
    );
  }
}
