import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../room.dart';
import 'membership/invite.dart';
import 'membership/join.dart';

class RoomBody extends StatelessWidget {
  const RoomBody({super.key, required this.controller});

  final RoomController controller;

  @override
  Widget build(BuildContext context) {
    final room = controller.room;
    final membership = room.membership;
    switch (membership) {
      case Membership.ban:
      // TODO: Handle this case.
      case Membership.invite:
      case Membership.knock:
        return MembershipInviteTile(controller: controller, room: room);
      case Membership.join:
      case Membership.leave:
        return MembershipJoinView(controller: controller, room: room);
    }
  }
}
