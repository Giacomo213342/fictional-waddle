import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'components/attachment_toolbar.dart';
import 'm_room_message/m_audio.dart';
import 'm_room_message/m_file.dart';
import 'm_room_message/m_image.dart';
import 'm_room_message/m_text.dart';
import 'm_room_message/m_video.dart';

final _textMessageKeyRegistry = <String, GlobalKey>{};
final _videoMessageKeyRegistry = <String, GlobalKey<State<VideoMessage>>>{};
final _imageMessageKeyRegistry = <String, GlobalKey>{};
final _audioMessageKeyRegistry = <String, GlobalKey<State<AudioMessage>>>{};
final _fileMessageKeyRegistry = <String, GlobalKey<State<FileMessage>>>{};

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
    final replyToEventId = this.replyToEventId;
    final globalKeyRegistryKey = replyToEventId == null
        ? event.eventId
        : '${event.eventId}-$replyToEventId';

    switch (event.messageType) {
      case MessageTypes.Sticker:
        return ImageMessage(
          key: _imageMessageKeyRegistry[globalKeyRegistryKey] ??= GlobalKey(),
          event: event,
        );
      case MessageTypes.Image:
        return AttachmentToolbar(
          event: event,
          child: ImageMessage(
            key: _imageMessageKeyRegistry[globalKeyRegistryKey] ??= GlobalKey(),
            event: event,
          ),
        );
      case MessageTypes.Video:
        return AttachmentToolbar(
          event: event,
          child: VideoMessage(
            key: _videoMessageKeyRegistry[globalKeyRegistryKey] ??=
                GlobalKey<State<VideoMessage>>(),
            event: event,
          ),
        );
      case MessageTypes.Audio:
        return AttachmentToolbar(
          event: event,
          child: AudioMessage(
            key: _audioMessageKeyRegistry[globalKeyRegistryKey] ??=
                GlobalKey<State<AudioMessage>>(),
            event: event,
          ),
        );
      case MessageTypes.File:
        return AttachmentToolbar(
          event: event,
          child: FileMessage(
            key: _fileMessageKeyRegistry[globalKeyRegistryKey] ??=
                GlobalKey<State<FileMessage>>(),
            event: event,
          ),
        );
      case MessageTypes.Text:
      case MessageTypes.Emote:
      case MessageTypes.Notice:
        return TextMessage(
          key: _textMessageKeyRegistry[globalKeyRegistryKey] ??= GlobalKey(),
          event: event,
          globalKeyRegistryKey: globalKeyRegistryKey,
        );
      default:
        return Text(
          event.calcLocalizedBodyFallback(const MatrixDefaultLocalizations()),
        );
    }
  }
}
