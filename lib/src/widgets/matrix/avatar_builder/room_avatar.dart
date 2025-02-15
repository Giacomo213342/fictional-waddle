import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'fullscreen_dialog_avatar.dart';
import 'mxc_avatar.dart';

class RoomAvatar extends StatelessWidget {
  const RoomAvatar({
    super.key,
    required this.room,
    this.dimension = 48,
    this.fit,
  });

  static Widget fullScreenButton({
    required BuildContext context,
    required Room room,
    double dimension = 48,
    BoxFit? fit,
  }) =>
      FullScreenAvatar.makeImageButton(
        context: context,
        child: RoomAvatar(
          room: room,
          dimension: dimension,
          fit: fit,
        ),
        uri: room.avatar,
        title: room.getLocalizedDisplayname(),
      );

  final Room room;
  final double dimension;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final factor = dimension / 48;
    final style = Theme.of(context).textTheme.headlineMedium;
    double? size = style?.fontSize;
    if (size != null) {
      size *= factor;
    }

    return FutureBuilder(
      future: room.avatar == null && room.directChatMatrixID != null
          // load the hero users if avatar null and could be gathered
          ? room.loadHeroUsers()
          : null,
      builder: (context, _) => MxcAvatar(
        uri: room.avatar,
        monogram: room.getLocalizedDisplayname(),
        dimension: dimension,
        fit: fit,
      ),
    );
  }
}
