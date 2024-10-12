import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room_list.dart';

class CommandPreviewTile extends StatelessWidget {
  const CommandPreviewTile({
    super.key,
    required this.command,
    this.description,
    required this.controller,
    required this.args,
  });

  final String command;
  final String? description;
  final RoomListController controller;
  final CommandArgs args;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return ListTile(
      title: Text('/$command'),
      subtitle: description != null ? Text(description) : null,
      onTap: () => controller.runCommand(command, args),
    );
  }
}
