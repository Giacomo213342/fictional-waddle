import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'mxc_avatar.dart';

class ProfileAvatarBuilder extends StatelessWidget {
  const ProfileAvatarBuilder({
    super.key,
    required this.userId,
    this.monogram,
    required this.client,
    this.dimension = 48,
  });

  final String userId;
  final String? monogram;
  final Client client;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: client.onUserProfileUpdate.stream.where((user) => user == userId),
      builder: (context, snapshot) {
        return FutureBuilder(
          future: client.getProfileFromUserId(userId),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            return MxcAvatar(
              uri: profile?.avatarUrl,
              client: client,
              monogram: profile?.displayName ?? monogram ?? userId,
              dimension: dimension,
            );
          },
        );
      },
    );
  }
}
