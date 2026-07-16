import 'package:matrix/matrix.dart';

import 'poll_event.dart';

extension SameMessageBubbleExtension on Event {
  bool isSameMessageBubble(Event other) {
    if (senderId != other.senderId) {
      return false;
    }
    if (redacted) {
      return true;
    }
    const messageTypes = {
      EventTypes.Message,
      EventTypes.Sticker,
      MatrixPollEventTypes.start,
      MatrixPollEventTypes.unstableStart,
    };
    return messageTypes.contains(type) &&
        messageTypes.contains(other.type) &&
        other.originServerTs.difference(originServerTs).abs().inMinutes < 5;
  }
}
