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

    final monogram = room.getLocalizedDisplayname();

    return FutureBuilder(
      future: room.loadHeroUsers(),
      builder: (context, _) => MxcAvatar(
        uri: room.avatar,
        monogram: monogram,
        dimension: dimension,
        fit: fit,
      ),
    );
  }
}
