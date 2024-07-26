import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'm_room_message/m_audio.dart';
import 'm_room_message/m_file.dart';
import 'm_room_message/m_image.dart';
import 'm_room_message/m_text.dart';
import 'm_room_message/m_video.dart';

final _textMessageKeyRegistry = <String, GlobalKey<State<TextMessage>>>{};
final _videoMessageKeyRegistry = <String, GlobalKey<State<VideoMessage>>>{};
final _imageMessageKeyRegistry = <String, GlobalKey>{};
final _audioMessageKeyRegistry = <String, GlobalKey<State<AudioMessage>>>{};
final _fileMessageKeyRegistry = <String, GlobalKey<State<FileMessage>>>{};

class RoomMessageContent extends StatelessWidget {
  const RoomMessageContent({super.key, required this.event});

  final Event event;

  Client get client => event.room.client;

  @override
  Widget build(BuildContext context) {
    switch (event.messageType) {
      case MessageTypes.Sticker:
      case MessageTypes.Image:
        return ImageMessage(
          key: _imageMessageKeyRegistry[event.eventId] ??= GlobalKey(),
          event: event,
        );
      case MessageTypes.Video:
        return VideoMessage(
          key: _videoMessageKeyRegistry[event.eventId] ??=
              GlobalKey<State<VideoMessage>>(),
          event: event,
        );
      case MessageTypes.Audio:
        return AudioMessage(
          key: _audioMessageKeyRegistry[event.eventId] ??=
              GlobalKey<State<AudioMessage>>(),
          event: event,
        );
      case MessageTypes.File:
        return FileMessage(
          key: _fileMessageKeyRegistry[event.eventId] ??=
              GlobalKey<State<FileMessage>>(),
          event: event,
        );
      case MessageTypes.Text:
      case MessageTypes.Emote:
        return TextMessage(
          key: _textMessageKeyRegistry[event.eventId] ??=
              GlobalKey<State<TextMessage>>(),
          event: event,
        );
      default:
        return Text(event.messageType);
    }
  }
}
