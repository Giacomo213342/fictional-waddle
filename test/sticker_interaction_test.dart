import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('stickers render as inert compact media, unlike images', () {
    final source = File(
      'lib/src/pages/room/components/event/m_room_message_content.dart',
    ).readAsStringSync();
    final stickerStart = source.indexOf('case MessageTypes.Sticker:');
    final imageStart = source.indexOf('case MessageTypes.Image:');
    final videoStart = source.indexOf('case MessageTypes.Video:');
    final stickerBranch = source.substring(stickerStart, imageStart);
    final imageBranch = source.substring(imageStart, videoStart);

    expect(stickerBranch, contains('ImageMessage(compact: true)'));
    expect(stickerBranch, isNot(contains('openFullscreen: true')));
    expect(imageBranch, contains('openFullscreen: true'));
  });
}
