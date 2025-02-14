import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import 'membership/invite.dart';
import 'membership/join.dart';

class RoomBody extends StatelessWidget {
  const RoomBody({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? RoomScope.of(context).room;
        final membership = room.membership;
        return switch (membership) {
          Membership.ban ||
          Membership.invite ||
          Membership.knock =>
            const MembershipInviteTile(),
          Membership.join || Membership.leave => const MembershipJoinView()
        };
      },
    );
  }
}
