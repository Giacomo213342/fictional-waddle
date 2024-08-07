import 'package:matrix/matrix.dart';

extension SameMessageBubbleExtension on Event {
  bool isSameMessageBubble(String relatedSenderId) {
    if (senderId != relatedSenderId) {
      return false;
    }
    if (redacted) {
      return true;
    }
    return [
      EventTypes.Message,
      EventTypes.Sticker,
    ].contains(
      type,
    );
  }
}
