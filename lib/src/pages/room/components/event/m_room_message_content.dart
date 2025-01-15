import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'components/attachment_toolbar.dart';
import 'm_room_message/m_audio.dart';
import 'm_room_message/m_file.dart';
import 'm_room_message/m_image.dart';
import 'm_room_message/m_text.dart';
import 'm_room_message/m_video.dart';
import 'm_room_message/msc_3935_cute_event.dart';

class RoomMessageContent extends StatelessWidget {
  const RoomMessageContent({
    super.key,
    required this.event,
    this.replyToEventId,
  });

  final Event event;
  final String? replyToEventId;

  Client get client => event.room.client;

  @override
  Widget build(BuildContext context) {
    switch (event.messageType) {
      case MessageTypes.Sticker:
        return ImageMessage(
          event: event,
        );
      cute_events:
      case CuteEventContent.eventType:
        return CuteEventMessage(
          event: event,
        );
      case MessageTypes.Image:
        return AttachmentToolbar(
          event: event,
          child: ImageMessage(
            event: event,
          ),
        );
      case MessageTypes.Video:
        return AttachmentToolbar(
          event: event,
          child: VideoMessage(
            event: event,
          ),
        );
      case MessageTypes.Audio:
        return AttachmentToolbar(
          event: event,
          child: AudioMessage(
            event: event,
          ),
        );
      case MessageTypes.File:
        return AttachmentToolbar(
          event: event,
          child: FileMessage(
            event: event,
          ),
        );
      case MessageTypes.Text:
      case MessageTypes.Emote:
      case MessageTypes.Notice:
        // compatibility with Element's party popper and snowflakes
        if (['\u{2744}', '\u{1F389}', '\u{2744}\u{fe0f}']
            .contains(event.body)) {
          continue cute_events;
        }
        return TextMessage(
          event: event,
        );
      default:
        return Text(
          event.calcLocalizedBodyFallback(const MatrixDefaultLocalizations()),
        );
    }
  }
}
