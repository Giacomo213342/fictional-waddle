import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../profile_builder.dart';
import 'mxc_avatar.dart';

class ProfileAvatarBuilder extends StatelessWidget {
  const ProfileAvatarBuilder({
    super.key,
    required this.userId,
    required this.client,
    this.dimension = 48,
  });

  final String userId;
  final Client client;
  final double dimension;

  @override
  Widget build(BuildContext context) => ProfileBuilder(
        userId: userId,
        client: client,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          return MxcAvatar(
            uri: profile?.avatarUrl,
            client: client,
            monogram: profile?.displayName ?? userId,
            dimension: dimension,
          );
        },
      );
}
