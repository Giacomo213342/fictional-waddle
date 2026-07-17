import 'package:matrix/matrix.dart';

typedef PolyculeDisplayEvent = ({Event event, bool isEdited});

extension PolyculeDisplayEventExtension on Event {
  /// Resolves replacement content without adopting the replacement event's
  /// identity. The Matrix SDK's `getDisplayEvent` returns a new Event built
  /// from the latest edit, including its event ID and timestamp. Those fields
  /// must continue to belong to the original message: receipts, five-minute
  /// grouping, replies and optimistic-send state all address that original.
  PolyculeDisplayEvent resolvePolyculeDisplayEvent(Timeline timeline) {
    final replacement = getDisplayEvent(timeline);
    if (identical(replacement, this)) {
      return (event: this, isEdited: false);
    }

    final displayContent = Map<String, dynamic>.from(replacement.content);
    final originalRelation = content['m.relates_to'];
    if (!displayContent.containsKey('m.relates_to') &&
        originalRelation is Map) {
      displayContent['m.relates_to'] = Map<String, dynamic>.from(
        originalRelation,
      );
    }

    return (
      event: Event(
        status: status,
        content: displayContent,
        type: type,
        eventId: eventId,
        senderId: senderId,
        originServerTs: originServerTs,
        unsigned: unsigned,
        prevContent: prevContent,
        stateKey: stateKey,
        redacts: redacts,
        room: room,
        originalSource: originalSource,
      ),
      isEdited: true,
    );
  }
}
