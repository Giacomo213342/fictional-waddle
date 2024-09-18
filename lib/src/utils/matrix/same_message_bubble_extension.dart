import 'package:matrix/matrix.dart';

extension SameMessageBubbleExtension on Event {
  bool isSameMessageBubble(Event other) {
    if (senderId != other.senderId) {
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
        ) &&
        other.originServerTs.difference(originServerTs).abs().inMinutes < 5;
  }
}
