import 'dart:async';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/matrix/blur_hash_indicator.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/retry_download_button.dart';
import '../../../../../widgets/matrix/tumbnail_aspect_ratio.dart';
import '../../../../../widgets/polycule_text_shadow.dart';

class VideoMessage extends StatefulWidget {
  const VideoMessage({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  State<VideoMessage> createState() => _VideoMessageState();
}

class _VideoMessageState extends State<VideoMessage>
    with AutomaticKeepAliveClientMixin<VideoMessage> {
  final Player player = Player();
  VideoController? controller;

  @override
  void initState() {
    controller = VideoController(player);
    super.initState();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
      child: ThumbnailAspectRatio(
        event: widget.event,
        child: MxcEncryptedFileBuilder<Playable, MatrixFile>(
          event: widget.event,
          attachmentTransformer: _makePlayable,
          builder: (context, thumbnail, attachment, retryCallback) {
            final playable = attachment.data;
            final thumb = thumbnail.data;
            if (playable == null) {
              final label = attachment.hasError
                  ? RetryDownloadButton(callback: retryCallback)
                  : const AsciiProgressIndicator();
              if (thumb is MatrixFile) {
                return Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Image.memory(
                      thumb.bytes,
                      gaplessPlayback: true,
                      fit: BoxFit.contain,
                    ),
                    PolyculeTextShadow(child: Center(child: label)),
                  ],
                );
              }

              return BlurHashIndicator(
                event: widget.event,
                label: label,
              );
            }
            return MaterialDesktopVideoControlsTheme(
              normal: MaterialDesktopVideoControlsThemeData(
                seekBarPositionColor: theme.colorScheme.primary,
                seekBarThumbColor: theme.colorScheme.primary,
              ),
              fullscreen: MaterialDesktopVideoControlsThemeData(
                seekBarPositionColor: theme.colorScheme.primary,
                seekBarThumbColor: theme.colorScheme.primary,
              ),
              child: MaterialVideoControlsTheme(
                normal: MaterialVideoControlsThemeData(
                  seekBarPositionColor: theme.colorScheme.primary,
                  seekBarThumbColor: theme.colorScheme.primary,
                ),
                fullscreen: MaterialVideoControlsThemeData(
                  seekBarPositionColor: theme.colorScheme.primary,
                  seekBarThumbColor: theme.colorScheme.primary,
                ),
                child: Video(
                  controller: controller!,
                  fill: Colors.transparent,
                  controls: AdaptiveVideoControls,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Playable?> _makePlayable(MatrixFile? file) async {
    if (file == null) {
      return null;
    }
    final playable = await Media.memory(file.bytes, type: file.mimeType);
    await player.open(playable);
    await player.pause();
    return playable;
  }

  @override
  bool get wantKeepAlive => true;
}
