import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../room.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key, required this.controller});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller.messageController,
      autofocus: !kIsWeb &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS),
      autocorrect: true,
      cursorWidth: 10,
      onSubmitted: (_) => controller.sendMessage(),
      expands: true,
      minLines: null,
      maxLines: null,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
        ),
        prefixText: 'm.text : ',
        helperText: 'format: org.matrix.custom.html',
        suffixIcon: IconButton(
          padding: const EdgeInsets.all(16.0),
          tooltip: AppLocalizations.of(context).send,
          icon: const Icon(Icons.send),
          onPressed: controller.sendMessage,
        ),
        labelText: 'm.room.message',
      ),
    );
  }
}
