import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../widgets/matrix/avatar_builder/user_avatar.dart';

class MessageUserAvatar extends StatelessWidget {
  const MessageUserAvatar({super.key, required this.event, this.onTap});

  final Event event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: event.fetchSenderUser(),
      builder: (context, snapshot) {
        final user = snapshot.data ?? event.senderFromMemoryOrFallback;

        return Tooltip(
          message: user.displayName ?? user.id,
          child: InkWell(
            onTap: onTap,
            child: UserAvatar(
              user: user,
              client: event.room.client,
              dimension: 32,
            ),
          ),
        );
      },
    );
  }
}
