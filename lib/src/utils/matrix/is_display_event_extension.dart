import 'package:matrix/matrix.dart';

import 'poll_event.dart';

bool isMatrixCallSignalingEventType(String type) =>
    type.startsWith('m.call.') || type.startsWith('org.matrix.call.');

extension IsDisplayEventExtension on Event {
  bool get shouldDisplayEvent {
    // Legacy 1:1 call events carry SDP, ICE candidates and call state. They
    // are transport signaling, not room history messages.
    if (isMatrixCallSignalingEventType(type)) {
      return false;
    }
    // do not show edit and reaction notices
    if ([
      RelationshipTypes.edit,
      RelationshipTypes.reaction,
    ].contains(relationshipType)) {
      return false;
    }
    // do not display redaction notices
    if ([EventTypes.Redaction].contains(type)) {
      return false;
    }
    if (isPollResponse ||
        const {
          MatrixPollEventTypes.end,
          MatrixPollEventTypes.unstableEnd,
        }.contains(type)) {
      return false;
    }
    // do not display avatar and display name change
    if (type == EventTypes.RoomMember &&
        [
          RoomMemberChangeType.displayname,
          RoomMemberChangeType.avatar,
        ].contains(roomMemberChangeType)) {
      return false;
    }
    // do not display key verification spam
    if ([
      EventTypes.KeyVerificationCancel,
      EventTypes.KeyVerificationReady,
      EventTypes.KeyVerificationStart,
      EventTypes.KeyVerificationAccept,
      EventTypes.KeyVerificationDone,
      'm.key.verification.key',
      'm.key.verification.mac',
    ].contains(type)) {
      return false;
    }

    return true;
  }
}
