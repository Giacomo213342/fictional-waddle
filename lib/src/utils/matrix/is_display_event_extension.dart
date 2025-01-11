import 'package:matrix/matrix.dart';

extension IsDisplayEventExtension on Event {
  bool get shouldDisplayEvent {
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
    // do not display avatar and display name change
    if (type == EventTypes.RoomMember &&
        [RoomMemberChangeType.displayname, RoomMemberChangeType.avatar]
            .contains(roomMemberChangeType)) {
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
