import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('timeline videos are thumbnail-only fullscreen launchers', () {
    final video = File(
      'lib/src/pages/room/components/event/m_room_message/m_video.dart',
    ).readAsStringSync();
    final content = File(
      'lib/src/pages/room/components/event/m_room_message_content.dart',
    ).readAsStringSync();

    final thumbnailStart = video.indexOf('class _VideoThumbnail');
    final fullscreenStart = video.indexOf('class _FullscreenVideo');
    final thumbnail = video.substring(thumbnailStart, fullscreenStart);

    expect(thumbnail, contains('ThumbnailRequest.thumbnailOnly'));
    expect(thumbnail, contains('fallbackToAttachment: false'));
    expect(thumbnail, isNot(contains('Video(')));
    expect(thumbnail, isNot(contains('Player(')));
    expect(content, contains('case MessageTypes.Video:'));
    expect(content, contains('openFullscreen: true'));
  });

  test('video playback exists only in the fullscreen implementation', () {
    final video = File(
      'lib/src/pages/room/components/event/m_room_message/m_video.dart',
    ).readAsStringSync();
    final toolbar = File(
      'lib/src/pages/room/components/event/components/attachment_toolbar.dart',
    ).readAsStringSync();

    expect(video, contains('class _FullscreenVideo'));
    expect(video, contains('ThumbnailRequest.attachmentOnly'));
    expect(video, contains('AdaptiveVideoControls'));
    expect(toolbar, contains('fullscreen: true'));
    expect(toolbar, contains('active: event.eventId == _event.eventId'));
  });
}
