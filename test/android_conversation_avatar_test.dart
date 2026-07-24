import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android conversation shortcuts use the Matrix room avatar', () {
    final pushHandler = File(
      'lib/src/utils/matrix/push_handler.dart',
    ).readAsStringSync();
    final plugin = File(
      'third_party/unifiedpush_android/android/src/main/kotlin/'
      'org/unifiedpush/flutter/connector/Plugin.kt',
    ).readAsStringSync();

    expect(pushHandler, contains('event.room.avatar?.downloadAndroidAvatar'));
    expect(pushHandler, contains("'avatarBytes': roomAvatarBytes"));
    expect(pushHandler, contains('ByteArrayAndroidBitmap(roomAvatarBytes)'));
    expect(plugin, contains('call.argument<ByteArray>("avatarBytes")'));
    expect(plugin, contains('IconCompat.createWithAdaptiveBitmap'));
    expect(plugin, contains('.setIcon(conversationIcon)'));
  });

  test('avatar lookup is cache-first and bounded', () {
    final pushHandler = File(
      'lib/src/utils/matrix/push_handler.dart',
    ).readAsStringSync();

    expect(pushHandler, contains('await database.getFile(this)'));
    expect(pushHandler, contains('await database.getFile(thumbnailUri)'));
    expect(
      pushHandler,
      contains('timeout(const Duration(milliseconds: 1250))'),
    );
  });
}
