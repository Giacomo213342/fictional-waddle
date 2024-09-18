import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../room.dart';
import 'msgtype_dropdown.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key, required this.controller});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: TextField(
        controller: controller.messageController,
        autofocus: !kIsWeb &&
            (Platform.isWindows || Platform.isLinux || Platform.isMacOS),
        autocorrect: true,
        cursorWidth: 10,
        onSubmitted: (_) => controller.sendMessage(),
        minLines: 1,
        maxLines: 15,
        decoration: InputDecoration(
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.zero,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: MsgtypeDropdown(controller: controller),
          helperText: '{ "format": "org.matrix.custom.html" }',
          suffixIcon: IconButton(
            padding: const EdgeInsets.all(16.0),
            tooltip: AppLocalizations.of(context).send,
            icon: const Icon(Icons.send),
            onPressed: controller.sendMessage,
          ),
          alignLabelWithHint: false,
          labelText: 'm.room.message',
        ),
      ),
    );
  }
}
