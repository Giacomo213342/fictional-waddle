import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../mxc_image.dart';
import 'components/monogram_text.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.client,
    this.dimension = 48,
  });

  final User user;
  final Client client;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final factor = dimension / 48;
    final style = Theme.of(context).textTheme.headlineMedium;
    double? size = style?.fontSize;
    if (size != null) {
      size *= factor;
    }

    final uri = user.avatarUrl;

    return Semantics(
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: dimension,
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: [
            Center(
              child: MonogramText(
                user.calcDisplayname(),
                style: style?.copyWith(fontSize: size),
                textAlign: TextAlign.center,
              ),
            ),
            if (uri != null)
              MxcImage(
                uri: uri,
                client: client,
                width: dimension,
                height: dimension,
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
    );
  }
}
