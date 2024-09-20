import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../room.dart';
import '../event/m_reply_container.dart';
import 'msgtype_dropdown.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key, required this.controller});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    final quotedEvent = controller.replyEvent ?? controller.editEvent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: ClipRect(
              child: SizedBox(
                height: quotedEvent == null ? 0 : null,
                child: Row(
                  children: [
                    if (quotedEvent != null)
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => ReplyContainer(
                            replyEvent: quotedEvent,
                            constraints: constraints,
                            globalKeySuffix: 'compose',
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: controller.clearRelatedEvent,
                        icon: const Icon(Icons.cancel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          TextField(
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
        ],
      ),
    );
  }
}
