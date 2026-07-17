import 'package:matrix/matrix.dart';

import 'call_event_summary.dart';
import 'poll_event.dart';

extension IsDisplayEventExtension on Event {
  bool get shouldDisplayEvent {
    // Only lifecycle milestones are room history. SDP, ICE candidates,
    // negotiation, answer selection, and stream metadata remain hidden.
    if (isMatrixCallSignalingEventType(type)) {
      return matrixCallLifecycleKind(type) != null;
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
