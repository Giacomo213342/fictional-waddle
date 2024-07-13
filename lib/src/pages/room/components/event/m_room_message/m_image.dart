import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/matrix/blur_hash_indicator.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/retry_download_button.dart';
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
          builder: (context, thumbnail, attachment, retryCallback) {
            final data = thumbnail.data ?? attachment.data;

            if (data == null) {
              final label = (thumbnail.hasError || attachment.hasError)
                  ? RetryDownloadButton(callback: retryCallback)
                  : const AsciiProgressIndicator();

              return BlurHashIndicator(
                event: event,
                label: label,
              );
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
