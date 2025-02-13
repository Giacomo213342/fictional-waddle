import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/matrix/avatar_builder/mxc_avatar.dart';
import '../../../../../widgets/matrix/blur_hash_indicator.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/retry_download_button.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/matrix/tumbnail_aspect_ratio.dart';
import '../../../../../widgets/mimed_image.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
      child: ThumbnailAspectRatio(
        child: MxcEncryptedFileBuilder<MatrixFile, MatrixFile>(
          event: EventScope.of(context).event,
          thumbnail: ThumbnailRequest.thumbnailOnly,
          builder: (context, thumbnail, attachment, retryCallback) {
            final data = thumbnail.data ?? attachment.data;

            final label = (thumbnail.hasError || attachment.hasError)
                ? RetryDownloadButton(callback: retryCallback)
                : const AsciiProgressIndicator();

            return Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                AnimatedOpacity(
                  opacity: data == null ? 1 : 0,
                  duration: MxcAvatar.kFadeDuration,
                  curve: Curves.easeInOut,
                  child: BlurHashIndicator(label: label),
                ),
                AnimatedOpacity(
                  opacity: data == null ? 0 : 1,
                  duration: MxcAvatar.kFadeDuration,
                  curve: Curves.easeInOut,
                  child: data == null
                      ? null
                      : MimedImage(
                          bytes: data.bytes,
                          name: data.name,
                          fit: BoxFit.contain,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
