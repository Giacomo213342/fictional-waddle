import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' hide Image;
import 'package:matrix/matrix.dart';

import '../ascii_progress_indicator.dart';

class BlurHashSpinner extends StatelessWidget {
  const BlurHashSpinner({
    super.key,
    required this.event,
    this.size = const Size(640, 360),
  });

  final Event event;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final info = event.infoMap as Map<String, Object?>?;
    final thumbnailInfo = event.thumbnailInfoMap as Map<String, Object?>?;
    final width = thumbnailInfo?['w'] as num?;
    final height = thumbnailInfo?['h'] as num?;
    final blurHash = info?['xyz.amorgan.blurhash'] as String?;
    if (blurHash is String) {
      return Image.memory(
        Uint8List.fromList(
          encodePng(
            BlurHash.decode(blurHash).toImage(
              width?.round() ?? size.width.round(),
              height?.round() ?? size.height.round(),
            ),
          ),
        ),
      );
    }
    return const AsciiProgressIndicator();
  }
}
