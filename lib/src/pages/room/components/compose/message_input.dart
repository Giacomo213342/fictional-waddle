import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import '../event/quoted_event.dart';
import 'compose_scope.dart';
import 'msgtype_dropdown.dart';
import 'poll_creation_dialog.dart';
import 'send_file_scope.dart';
import 'type_ahead_helper.dart';

class MessageInput extends StatelessWidget {
  const MessageInput({super.key, this.onStartedTyping});

  final VoidCallback? onStartedTyping;

  @override
  Widget build(BuildContext context) {
    final compose = ComposeScope.of(context);
    final typeAheadHelper = TypeAheadHelper(
      controller: compose.messageController,
      room: RoomScope.of(context).room,
      l10n: AppLocalizations.of(context),
    );

    final quotedEvent = compose.replyEvent ?? compose.editEvent;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 150),
            child: ClipRect(
              child: Dismissible(
                key: Key(quotedEvent?.eventId ?? 'empty'),
                direction: DismissDirection.down,
                onDismissed: (_) => compose.clearRelatedEvent(),
                child: SizedBox(
                  height: quotedEvent == null ? 0 : null,
                  child: Row(
                    children: [
                      if (quotedEvent != null)
                        Expanded(
                          child: EventScope(
                            event: quotedEvent,
                            child: const QuotedEvent(),
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: compose.clearRelatedEvent,
                          icon: const Icon(Icons.cancel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          TypeAheadField<TypeAheadOption>(
            focusNode: compose.messageFocusNode,
            controller: compose.messageController,
            suggestionsController: compose.suggestionsController,
            builder: (context, textEditingController, focusNode) {
              return TextField(
                controller: textEditingController,
                focusNode: focusNode,
                autofocus:
                    !kIsWeb &&
                    (Platform.isWindows ||
                        Platform.isLinux ||
                        Platform.isMacOS),
                autocorrect: true,
                contentInsertionConfiguration: ContentInsertionConfiguration(
                  onContentInserted: SendFileScope.of(
                    context,
                  ).sendKeyboardSticker,
                  allowedMimeTypes: [
                    ...kDefaultContentInsertionMimeTypes,
                    'image/svg+xml',
                    'image/avif',
                    'image/apng',
                    // Lottie
                    'application/json',
                    'application/gzip',
                    'application/zip',
                  ],
                ),
                cursorWidth: 10,
                onChanged: (value) {
                  if (value.isNotEmpty) onStartedTyping?.call();
                },
                onSubmitted: (_) => compose.sendMessage(),
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 15,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  prefixIcon: const MsgtypeDropdown(),
                  helperText: '{ "format": "org.matrix.custom.html" }',
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        tooltip: 'Create poll',
                        icon: const Icon(Icons.poll_outlined),
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => PollCreationDialog(
                            room: RoomScope.of(context).room,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: AppLocalizations.of(context).send,
                        icon: const Icon(Icons.send),
                        onPressed: compose.sendMessage,
                      ),
                    ],
                  ),
                  alignLabelWithHint: false,
                  labelText: 'm.room.message',
                ),
              );
            },
            direction: VerticalDirection.up,
            hideOnEmpty: true,
            itemBuilder: typeAheadHelper.itemBuilder,
            onSelected: typeAheadHelper.onSelected,
            suggestionsCallback: typeAheadHelper.suggestionsCallback,
            listBuilder: typeAheadHelper.listBuilder,
          ),
        ],
      ),
    );
  }
}
