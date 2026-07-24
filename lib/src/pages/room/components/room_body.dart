import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/matrix/scopes/room_scope.dart';
import 'membership/invite.dart';
import 'membership/join.dart';

class RoomBody extends StatefulWidget {
  const RoomBody({
    super.key,
  });

  @override
  State<RoomBody> createState() => _RoomBodyState();
}

class _RoomBodyState extends State<RoomBody> {
  StreamSubscription<SyncUpdate>? _roomSubscription;
  Room? _room;
  Membership? _membership;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final room = RoomScope.of(context).room;
    if (_room?.id == room.id && identical(_room?.client, room.client)) {
      return;
    }
    _roomSubscription?.cancel();
    _room = room;
    _membership = room.membership;
    _roomSubscription = room.client.onSync.stream
        .where((update) => _updatedRoomIds(update).contains(room.id))
        .listen((_) => _refreshMembership(room));
  }

  @override
  void dispose() {
    _roomSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final membership = _membership ?? RoomScope.of(context).room.membership;
    return switch (membership) {
      Membership.ban ||
      Membership.invite ||
      Membership.knock =>
        const MembershipInviteTile(),
      Membership.join || Membership.leave => const MembershipJoinView()
    };
  }

  void _refreshMembership(Room originalRoom) {
    if (!mounted) {
      return;
    }
    final room =
        originalRoom.client.getRoomById(originalRoom.id) ?? originalRoom;
    final membership = room.membership;
    if (membership == _membership) {
      return;
    }
    setState(() {
      _room = room;
      _membership = membership;
    });
  }
}

Iterable<String> _updatedRoomIds(SyncUpdate update) sync* {
  yield* update.rooms?.join?.keys ?? const [];
  yield* update.rooms?.leave?.keys ?? const [];
  yield* update.rooms?.invite?.keys ?? const [];
  yield* update.rooms?.knock?.keys ?? const [];
}
