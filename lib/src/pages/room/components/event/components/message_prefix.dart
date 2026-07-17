import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../router/extensions/go_router_path_extension.dart';
import '../../../../../utils/matrix/neighboaring_event_extension.dart';
import '../../../../../utils/matrix/polycule_display_event_extension.dart';
import '../../../../../utils/matrix/same_message_bubble_extension.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../../../user_page/user_page.dart';
import '../../message_user_avatar.dart';

class MessagePrefix extends StatelessWidget {
  const MessagePrefix({super.key});

  @override
  Widget build(BuildContext context) {
    final timeline = TimelineScope.of(context).timeline;
    final event = EventScope.of(
      context,
    ).event.resolvePolyculeDisplayEvent(timeline).event;
    final eventIndex = timeline.indexOfLogicalEvent(event);
    final nextEvent = timeline.getNextDisplayEvent(
      eventIndex,
    );

    final isOwnMessage = event.senderId == event.room.client.userID;

    final nextMessageSameSender =
        nextEvent?.isSameMessageBubble(event) ?? false;
    final showOtherSenderAvatar = !isOwnMessage && !nextMessageSameSender;

    Widget? prefix;

    if (event.redacted) {
      prefix = const Icon(Icons.delete);
    }

    if (showOtherSenderAvatar) {
      prefix = MessageUserAvatar(
        event: event,
        onTap: () => context.pushMultiClient(
          UserPage.makeRoomRouteName(event.room.id, event.senderId),
        ),
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
    } else if (isOwnMessage && event.redacted) {
      prefix = const Icon(Icons.delete);
    } else {
      prefix = null;
    }

    return IconTheme(
      data: IconTheme.of(context).copyWith(size: 16),
      child: SelectionArea(
        child: SizedBox.square(dimension: 32, child: prefix),
      ),
    );
  }
}
