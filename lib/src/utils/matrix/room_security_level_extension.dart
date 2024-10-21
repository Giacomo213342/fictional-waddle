import 'dart:async';

import 'package:matrix/matrix.dart';

enum RoomSecurityState {
  wtf,
  public,
  publicKnock,
  open,
  knock,
  space,
  unpublic,
  encrypted,
  verifiedEncrypted,
}

extension PolyculeRoomSecurityLevel on Room {
  FutureOr<RoomSecurityState> calcRoomSecurityState() {
    if (encrypted && joinRules != JoinRules.public) {
      return calcEncryptionHealthState().then((health) {
        switch (health) {
          case EncryptionHealthState.allVerified:
            return RoomSecurityState.verifiedEncrypted;
          case EncryptionHealthState.unverifiedDevices:
            return RoomSecurityState.encrypted;
        }
      });
    }
    switch (joinRules) {
      case JoinRules.public:
        if (canonicalAlias.isNotEmpty) {
          return RoomSecurityState.public;
        } else {
          return RoomSecurityState.open;
        }
      case JoinRules.knock:
        if (canonicalAlias.isNotEmpty) {
          return RoomSecurityState.publicKnock;
        } else {
          return RoomSecurityState.knock;
        }
      // space
      case JoinRules.restricted:
      case JoinRules.knockRestricted:
        return RoomSecurityState.space;
      case JoinRules.invite:
      case JoinRules.private:
        return RoomSecurityState.unpublic;
      case null:
    }
    return RoomSecurityState.wtf;
  }
}
