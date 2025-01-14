import 'package:matrix/matrix.dart';

extension AutoplayAnimatedContentExtension on Client {
  static const _elementWebKey = 'im.vector.web.settings';

  /// returns whether user preferences configured to autoplay motion
  /// message content such as gifs, webp, apng, videos or animations.
  bool? get autoplayAnimatedContent {
    if (!accountData.containsKey(_elementWebKey)) {
      return null;
    }
    try {
      final elementWebData = accountData[_elementWebKey]?.content;
      return elementWebData?['autoplayGifs'] as bool?;
    } catch (e) {
      return null;
    }
  }

  Future<void> setAutoplayAnimatedContent(bool autoplay) async {
    final elementWebData = accountData[_elementWebKey]?.content ?? {};
    elementWebData['autoplayGifs'] = autoplay;
    final uid = userID;
    if (uid != null) {
      await setAccountData(
        uid,
        _elementWebKey,
        elementWebData,
      );
    }
  }
}
