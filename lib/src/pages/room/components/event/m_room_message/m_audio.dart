import 'dart:async';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';

class AudioMessage extends StatefulWidget {
  const AudioMessage({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage>
    with
        AutomaticKeepAliveClientMixin<AudioMessage>,
        TickerProviderStateMixin<AudioMessage> {
  final player = AudioPlayer();
  late AnimationController iconAnimation;

  StreamSubscription<PlayerState>? _playerStateSubscription;

  @override
  void initState() {
    _playerStateSubscription =
        player.playerStateStream.listen(_handlePlayerState);

    iconAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    super.initState();
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    player.dispose();

    iconAnimation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    JustAudioMediaKit.title = AppLocalizations.of(context).appName;
    return SelectionArea(
      child: SizedBox(
        height: 96,
        child: MxcEncryptedFileBuilder<Duration, MatrixFile>(
          event: widget.event,
          attachmentTransformer: _makeAudio,
          thumbnail: ThumbnailRequest.attachmentOnly,
          builder: (context, thumbnail, attachment, retryCallback) {
            return ListTile(
              leading: AnimatedBuilder(
                builder: (context, _) {
                  return IconButton(
                    onPressed:
                        attachment.data is Duration ? _togglePlayback : null,
                    icon: AnimatedIcon(
                      icon: AnimatedIcons.play_pause,
                      progress: iconAnimation,
                    ),
                  );
                },
                animation: iconAnimation,
              ),
              title: SizedBox(
                child: StreamBuilder<Duration>(
                  stream: player.positionStream,
                  builder: (context, snapshot) {
                    int position = snapshot.data?.inMilliseconds ?? 0;
                    var durationMilliseconds = player.duration?.inMilliseconds;
                    if (durationMilliseconds == null ||
                        durationMilliseconds == 0) {
                      durationMilliseconds = 1;
                    }
                    return Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Flexible(
                          flex: position,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Transform.scale(
                          scale: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const SizedBox.square(dimension: 4),
                          ),
                        ),
                        Flexible(
                          flex: durationMilliseconds - position,
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            '${snapshot.data?.inSeconds ?? 0} / ${player.duration?.inSeconds ?? 0}',
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<Duration?> _makeAudio(MatrixFile? file) async {
    if (file == null) {
      return null;
    }
    final source = MatrixFileAudioSource(file);

    final duration = await player.setAudioSource(source, preload: true);
    await player.pause();
    await player.seek(Duration.zero);
    await player.setLoopMode(LoopMode.off);
    return duration;
  }

  Future<void> _togglePlayback() async {
    if (player.playing) {
      await player.pause();
    } else {
      try {
        await player.play();
      } catch (e) {
        // TODO: somehow detect failure
        await player.stop();
      }
    }
  }

  Future<void> _handlePlayerState(PlayerState playerState) async {
    if (!playerState.playing) {
      // TODO: somehow detect failure
      iconAnimation.animateBack(0);
    } else {
      iconAnimation.animateTo(1);
    }
    switch (playerState.processingState) {
      case ProcessingState.idle:
      case ProcessingState.loading:
      case ProcessingState.buffering:
      case ProcessingState.ready:
        break;
      case ProcessingState.completed:
        await player.stop();
        await player.seek(Duration.zero);
        break;
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class MatrixFileAudioSource extends StreamAudioSource {
  MatrixFileAudioSource(this.file);

  final MatrixFile file;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) {
    start = start ?? 0;
    end = end ?? file.bytes.length;

    return Future.value(
      StreamAudioResponse(
        sourceLength: file.bytes.length,
        contentLength: end - start,
        offset: start,
        contentType: file.mimeType,
        stream: Stream.value(
          file.bytes.skip(start).take(end - start).toList(),
        ),
      ),
    );
  }
}
