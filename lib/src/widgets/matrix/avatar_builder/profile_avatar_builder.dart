import 'package:flutter/material.dart';

import '../profile_builder.dart';
import 'fullscreen_dialog_avatar.dart';
import 'mxc_avatar.dart';

class ProfileAvatarBuilder extends StatelessWidget {
  const ProfileAvatarBuilder({
    super.key,
    required this.userId,
    this.dimension = 48,
    this.canOpenFullscreen = false,
  });

  final String userId;
  final double dimension;
  final bool canOpenFullscreen;

  @override
  Widget build(BuildContext context) => ProfileBuilder(
        userId: userId,
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final monogram = profile?.displayName ?? userId;

          return FullScreenAvatar.makeImageButton(
            context: context,
            child: MxcAvatar(
              uri: profile?.avatarUrl,
              monogram: monogram,
              dimension: dimension,
            ),
            uri: canOpenFullscreen ? profile?.avatarUrl : null,
            title: monogram,
          );
        },
      );
}
