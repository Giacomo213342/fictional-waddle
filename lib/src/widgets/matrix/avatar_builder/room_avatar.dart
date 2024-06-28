import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../mxc_uri_image.dart';
import 'components/monogram_text.dart';

class RoomAvatar extends StatelessWidget {
  const RoomAvatar({super.key, required this.room, this.dimension = 48});

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

    return Semantics(
      excludeSemantics: true,
      child: ClipRect(
        child: SizedBox.square(
          dimension: dimension,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Center(
                child: MonogramText(
                  room.getLocalizedDisplayname(),
                  style: style?.copyWith(fontSize: size),
                  textAlign: TextAlign.center,
                ),
              ),
              if (uri != null)
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: MxcUriImage(
                    uri: uri,
                    client: room.client,
                    width: dimension,
                    height: dimension,
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
