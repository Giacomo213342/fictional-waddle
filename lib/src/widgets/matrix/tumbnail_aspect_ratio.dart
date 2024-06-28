import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class ThumbnailAspectRatio extends StatelessWidget {
  const ThumbnailAspectRatio({
    super.key,
    required this.event,
    required this.child,
  });

  final Event event;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final thumbnailInfo = event.thumbnailInfoMap as Map<String, Object?>?;
    final info = event.infoMap as Map<String, Object?>?;

    final width = thumbnailInfo?['w'] as num? ?? info?['w'] as num?;
    final height = thumbnailInfo?['h'] as num? ?? info?['h'] as num?;
    if (height is num && width is num) {
      return AspectRatio(
        aspectRatio: width / height,
        child: child,
      );
    }
    return child;
  }
}
