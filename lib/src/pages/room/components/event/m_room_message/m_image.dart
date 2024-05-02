import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' hide Image;
import 'package:matrix/matrix.dart';

import '../../../../../widgets/ascii_progress_indicator.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 320,
      child: FutureBuilder(
        key: ValueKey(event.attachmentMxcUrl),
        future: event.downloadAndDecryptAttachment(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            final info = event.infoMap as Map<String, Object?>?;
            final thumbnailInfo =
                event.thumbnailInfoMap as Map<String, Object?>?;
            final width = thumbnailInfo?['w'] as num?;
            final height = thumbnailInfo?['h'] as num?;
            final blurhash = info?['xyz.amorgan.blurhash'] as String?;
            if (blurhash is String) {
              return Image.memory(
                Uint8List.fromList(
                  encodePng(
                    BlurHash.decode(blurhash)
                        .toImage(width?.round() ?? 320, height?.round() ?? 320),
                  ),
                ),
              );
            }
            return const AsciiProgressIndicator();
          }
          return Image.memory(data.bytes);
        },
      ),
    );
  }
}
