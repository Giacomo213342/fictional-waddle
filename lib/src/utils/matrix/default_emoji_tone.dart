import 'package:emoji_extension/emoji_extension.dart';
import 'package:matrix/matrix.dart';

extension DefaultEmojiTone on Client {
  static const _emoteConfigKey = 'im.fluffychat.emote_config';

  /// returns whether user preferences configured to autoplay motion
  /// message content such as gifs, webp, apng, videos or animations.
  SkinTone? get defaultEmojiTone {
    if (!accountData.containsKey(_emoteConfigKey)) {
      return null;
    }
    try {
      final fluffyChatData = accountData[_emoteConfigKey]?.content;
      final encoded = fluffyChatData?['tone'] as String?;
      switch (encoded) {
        case 'light':
          return SkinTone.light;
        case 'mediumLight':
          return SkinTone.mediumLight;
        case 'medium':
          return SkinTone.medium;
        case 'mediumDark':
          return SkinTone.mediumDark;
        case 'dark':
          return SkinTone.dark;
        default:
          return null;
      }
    } catch (e) {
      Logs().w('Unknown emoji tone.', e);
      return null;
    }
  }

  Future<void> setDefaultEmojiTone(SkinTone? tone) async {
    final fluffyChatData = accountData[_emoteConfigKey]?.content ?? {};
    final name = tone?.name;
    fluffyChatData['tone'] = name;
    final uid = userID;
    if (uid != null) {
      await setAccountData(
        uid,
        _emoteConfigKey,
        fluffyChatData,
      );
    }
  }
}
