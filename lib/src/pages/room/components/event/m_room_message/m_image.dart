import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../widgets/matrix/blur_hash_spinner.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/tumbnail_aspect_ratio.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
      child: ThumbnailAspectRatio(
        event: event,
        child: MxcEncryptedFileBuilder<MatrixFile, MatrixFile>(
          event: event,
          thumbnail: ThumbnailRequest.thumbnailOnly,
          builder: (context, thumbnail, attachment) {
            final data = thumbnail.data ?? attachment.data;
            if (data == null) {
              return BlurHashSpinner(event: event);
            }
            return Image.memory(
              data.bytes,
              gaplessPlayback: true,
              fit: BoxFit.contain,
            );
          },
        ),
      ),
    );
  }
}
