import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import 'fullscreen_dialog_avatar.dart';
import 'mxc_avatar.dart';

class RoomAvatar extends StatelessWidget {
  const RoomAvatar({super.key, required this.room, this.dimension = 48});

  static Widget fullScreenButton({
    required BuildContext context,
    required Room room,
    double dimension = 48,
  }) =>
      FullScreenAvatar.makeImageButton(
        context: context,
        child: RoomAvatar(
          room: room,
          dimension: dimension,
        ),
        uri: room.avatar,
        title: room.getLocalizedDisplayname(),
      );

  final Room room;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final factor = dimension / 48;
    final style = Theme.of(context).textTheme.headlineMedium;
    double? size = style?.fontSize;
    if (size != null) {
      size *= factor;
    }

    final uri = room.avatar;
    final monogram = room.getLocalizedDisplayname();

    return MxcAvatar(
      uri: uri,
      monogram: monogram,
      dimension: dimension,
    );
  }
}
