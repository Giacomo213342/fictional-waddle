import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../message_user_avatar.dart';
import 'edit_tooltip.dart';

class MessageSuffix extends StatelessWidget {
  const MessageSuffix({
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
    final showOwnAvatar = isOwnMessage && !nextMessageSameSender;

    Widget? editNotice;

    if (event.redacted) {
      editNotice = const Icon(Icons.delete);
    } else if (editEvent != null) {
      editNotice = EditTooltip(editEvent: editEvent);
    }

    Widget avatar = MessageUserAvatar(
      event: event,
    );

    if (event.messageType == MessageTypes.Notice) {
      avatar = Stack(
        alignment: Alignment.bottomRight,
        children: [
          avatar,
          const Padding(
            padding: EdgeInsets.all(2.0),
            child: Icon(Icons.smart_toy),
          ),
        ],
      );
    }

    return IconTheme(
      data: IconTheme.of(context).copyWith(size: 16),
      child: SelectionArea(
        child: SizedBox.square(
          dimension: 32,
          child: showOwnAvatar
              ? avatar
              : !isOwnMessage
                  ? editNotice
                  : null,
        ),
      ),
    );
  }
}
