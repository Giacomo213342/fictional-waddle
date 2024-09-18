import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../message_user_avatar.dart';
import 'edit_tooltip.dart';

class MessagePrefix extends StatelessWidget {
  const MessagePrefix({
    super.key,
    required this.event,
    this.editEvent,
    required this.isOwnMessage,
    required this.nextMessageSameSender,
  });

  final Event event;
  final Event? editEvent;
  final bool isOwnMessage;
  final bool nextMessageSameSender;

  @override
  Widget build(BuildContext context) {
    final editEvent = this.editEvent;

    final showOtherSenderAvatar = !isOwnMessage && !nextMessageSameSender;
    Widget? prefix;

    Widget? editNotice;

    if (event.redacted) {
      editNotice = const Icon(Icons.delete);
    } else if (editEvent != null) {
      editNotice = EditTooltip(editEvent: editEvent);
    }

    if (showOtherSenderAvatar) {
      prefix = MessageUserAvatar(
        event: event,
      );
      if (event.messageType == MessageTypes.Notice) {
        prefix = Stack(
          alignment: Alignment.bottomRight,
          children: [
            prefix,
            const Padding(
              padding: EdgeInsets.all(2.0),
              child: Icon(Icons.smart_toy),
            ),
          ],
        );
      }
    } else if (event.status.isError) {
      prefix = IconButton(
        tooltip: AppLocalizations.of(context).retrySending,
        onPressed: event.sendAgain,
        icon: const Icon(Icons.restart_alt),
      );
    } else if (event.status.isSending) {
      prefix = IconButton(
        tooltip: AppLocalizations.of(context).cancelSending,
        onPressed: event.cancelSend,
        icon: const Icon(Icons.cancel_rounded),
      );
    } else if (isOwnMessage) {
      prefix = editNotice;
    } else {
      prefix = null;
    }

    return IconTheme(
      data: IconTheme.of(context).copyWith(size: 16),
      child: SelectionArea(
        child: SizedBox.square(
          dimension: 32,
          child: prefix,
        ),
      ),
    );
  }
}
