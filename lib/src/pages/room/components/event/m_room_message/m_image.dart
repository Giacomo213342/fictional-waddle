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
  const ImageMessage({
    super.key,
    this.compact = false,
    this.fullscreen = false,
  });

  final bool compact;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    final description = imageDescriptionForEvent(event);
    final image = Semantics(
      image: true,
      label: description ?? event.body,
      child: ThumbnailAspectRatio(
        child: MxcEncryptedFileBuilder<MatrixFile, MatrixFile>(
          event: event,
          thumbnail: fullscreen
              ? ThumbnailRequest.attachmentOnly
              : ThumbnailRequest.thumbnailOnly,
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
    if (fullscreen) {
      return SizedBox.expand(child: image);
    }
    return ConstrainedBox(
      constraints: compact
          ? const BoxConstraints(maxHeight: 220, maxWidth: 220)
          : const BoxConstraints(maxHeight: 512, maxWidth: 512),
      child: image,
    );
  }
}

String? imageDescriptionForEvent(Event event) {
  final body = event.body.trim();
  final filename = event.content['filename'];
  if (body.isEmpty || filename is! String || body == filename.trim()) {
    return null;
  }
  return body;
}
