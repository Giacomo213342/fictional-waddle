import 'package:flutter/material.dart';

import 'package:emoji_extension/emoji_extension.dart';
import 'package:matrix/matrix.dart';

import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../utils/matrix/poll_event.dart';
import 'components/attachment_toolbar.dart';
import 'event_fallback_text.dart';
import 'm_room_message/m_audio.dart';
import 'm_room_message/m_file.dart';
import 'm_room_message/m_image.dart';
import 'm_room_message/m_text.dart';
import 'm_room_message/m_video.dart';
import 'm_room_message/msc_3935_cute_event.dart';
import 'm_poll.dart';

class RoomMessageContent extends StatelessWidget {
  const RoomMessageContent({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    if (event.redacted) {
      return const EventFallbackText();
    }
    if (event.isPollStart) {
      return const PollMessage();
    }
    switch (event.messageType) {
      case MessageTypes.Sticker:
        final isOwnMessage = event.senderId == event.room.client.userID;
        return AttachmentToolbar(
          showToolbar: false,
          child: Align(
            alignment:
                isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
            child: const SizedBox(
              width: 220,
              height: 220,
              child: ImageMessage(compact: true),
            ),
          ),
        );
      cute_events:
      case CuteEventContent.eventType:
        return const CuteEventMessage();
      case MessageTypes.Image:
        final description = imageDescriptionForEvent(event);
        return AttachmentToolbar(
          showToolbar: false,
          openFullscreen: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ImageMessage(key: ValueKey(event)),
              if (description != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
                  child: Text(description),
                ),
            ],
          ),
        );
      case MessageTypes.Video:
        return AttachmentToolbar(
          openFullscreen: true,
          child: VideoMessage(key: ValueKey(event)),
        );
      case MessageTypes.Audio:
        return AudioMessage(key: ValueKey(event));
      case MessageTypes.File:
        return const AttachmentToolbar(child: FileMessage());
      case MessageTypes.Text:
      case MessageTypes.Emote:
      case MessageTypes.Notice:
        // compatibility with Element's emotes :
        if ([
          // party popper
          '\u{2744}',
          // snowflakes
          '\u{1f389}',
          '\u{2744}\u{fe0f}',
          // aliens
          '\u{1f47e}',
          // heart with ribbon
          '\u{1f49d}',
          // rain
          '\u{1f327}',
          '\u{1f327}\u{fe0f}',
        ].contains(
          event.messageType == MessageTypes.Emote
              ? event.body.emojis.firstOrNull?.value
              : event.body,
        )) {
          continue cute_events;
        }
        return const TextMessage();
      default:
        return const EventFallbackText();
    }
  }
}
