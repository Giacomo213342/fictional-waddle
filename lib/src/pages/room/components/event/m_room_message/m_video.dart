import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/matrix/avatar_builder/mxc_avatar.dart';
import '../../../../../widgets/matrix/blur_hash_indicator.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/retry_download_button.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/matrix/tumbnail_aspect_ratio.dart';
import '../../../../../widgets/mimed_image.dart';
import '../../../../../widgets/polycule_text_shadow.dart';

class VideoMessage extends StatelessWidget {
  const VideoMessage({
    super.key,
    this.fullscreen = false,
    this.active = true,
  });

  final bool fullscreen;
  final bool active;

  @override
  Widget build(BuildContext context) =>
      fullscreen ? _FullscreenVideo(active: active) : const _VideoThumbnail();
}

class _VideoThumbnail extends StatelessWidget {
  const _VideoThumbnail();

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
        child: ThumbnailAspectRatio(
          child: MxcEncryptedFileBuilder<Never, MatrixFile>(
            event: EventScope.of(context).event,
            thumbnail: ThumbnailRequest.thumbnailOnly,
            fallbackToAttachment: false,
            builder: (context, thumbnail, attachment, retryCallback) {
              final thumb = thumbnail.data;
              final label = thumbnail.hasError
                  ? RetryDownloadButton(callback: retryCallback)
                  : const AsciiProgressIndicator();
              return Stack(
                alignment: Alignment.center,
                fit: StackFit.expand,
                children: [
                  AnimatedOpacity(
                    opacity: thumb == null ? 1 : 0,
                    duration: MxcAvatar.kFadeDuration,
                    curve: Curves.easeInOut,
                    child: BlurHashIndicator(label: label),
                  ),
                  if (thumb != null)
                    MimedImage(
                      bytes: thumb.bytes,
                      fit: BoxFit.contain,
                      name: thumb.name,
                    ),
                  const PolyculeTextShadow(
                    child: Center(
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _FullscreenVideo extends StatefulWidget {
  const _FullscreenVideo({required this.active});

  final bool active;

  @override
  State<_FullscreenVideo> createState() => _FullscreenVideoState();
}

class _FullscreenVideoState extends State<_FullscreenVideo> {
  final Player _player = Player();
  late final VideoController _controller = VideoController(_player);

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _FullscreenVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active && !widget.active) {
      unawaited(_player.pause());
    }
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: MxcEncryptedFileBuilder<Playable, MatrixFile>(
        event: EventScope.of(context).event,
        thumbnail: ThumbnailRequest.attachmentOnly,
        attachmentTransformer: _makePlayable,
        builder: (context, thumbnail, attachment, retryCallback) {
          final playable = attachment.data;
          if (attachment.hasError) {
            return Center(child: RetryDownloadButton(callback: retryCallback));
          }
          if (playable == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return Video(
            controller: _controller,
            fill: Colors.black,
            controls: AdaptiveVideoControls,
          );
        },
      ),
    );
  }

  Future<Playable?> _makePlayable(MatrixFile? file) async {
    if (file == null) {
      return null;
    }
    final playable = await Media.memory(file.bytes, type: file.mimeType);
    await _player.open(playable);
    return playable;
  }
}
