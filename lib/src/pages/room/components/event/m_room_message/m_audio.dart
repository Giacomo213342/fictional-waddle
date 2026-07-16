import 'dart:async';

import 'package:flutter/material.dart';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_media_kit/just_audio_media_kit.dart';
import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/settings_manager.dart';

class AudioMessage extends StatefulWidget {
  const AudioMessage({
    super.key,
  });

  @override
  State<AudioMessage> createState() => _AudioMessageState();
}

class _AudioMessageState extends State<AudioMessage>
    with AutomaticKeepAliveClientMixin<AudioMessage> {
  static const _playbackSpeeds = [0.5, 1.0, 1.5, 2.0];

  final player = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;
  ValueNotifier<double>? _speedNotifier;
  Duration? _dragPosition;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription =
        player.playerStateStream.listen(_handlePlayerState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = SettingsManager.of(context).audioPlaybackSpeed;
    if (identical(_speedNotifier, notifier)) return;
    _speedNotifier?.removeListener(_applyPlaybackSpeed);
    _speedNotifier = notifier..addListener(_applyPlaybackSpeed);
    _applyPlaybackSpeed();
  }

  @override
  void dispose() {
    _speedNotifier?.removeListener(_applyPlaybackSpeed);
    _playerStateSubscription?.cancel();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    JustAudioMediaKit.title = AppLocalizations.of(context).appName;
    return MxcEncryptedFileBuilder<Duration, MatrixFile>(
      event: EventScope.of(context).event,
      attachmentTransformer: _makeAudio,
      thumbnail: ThumbnailRequest.attachmentOnly,
      builder: (context, thumbnail, attachment, retryCallback) {
        final loaded = attachment.hasData;
        final duration = attachment.data ?? player.duration ?? Duration.zero;
        return ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 230, maxWidth: 340),
          child: Material(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(18),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 8, 7),
              child: Row(
                children: [
                  _buildLeading(attachment, retryCallback),
                  const SizedBox(width: 6),
                  Expanded(child: _buildProgress(loaded, duration)),
                  const SizedBox(width: 2),
                  _buildSpeedSelector(loaded),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeading(
    AsyncSnapshot<Duration?> attachment,
    VoidCallback? retryCallback,
  ) {
    if (attachment.hasError) {
      return IconButton.filledTonal(
        tooltip: AppLocalizations.of(context).retry,
        onPressed: retryCallback,
        icon: const Icon(Icons.refresh),
      );
    }
    if (!attachment.hasData) {
      return const SizedBox.square(
        dimension: 48,
        child: Padding(
          padding: EdgeInsets.all(13),
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      );
    }
    return IconButton.filledTonal(
      onPressed: _togglePlayback,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 120),
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: Icon(
          _playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
          key: ValueKey(_playing),
        ),
      ),
    );
  }

  Widget _buildProgress(bool loaded, Duration duration) {
    return StreamBuilder<Duration>(
      stream: player.positionStream,
      initialData: player.position,
      builder: (context, snapshot) {
        final durationMs = duration.inMilliseconds;
        final streamedPosition = snapshot.data ?? Duration.zero;
        final visiblePosition = _dragPosition ?? streamedPosition;
        final positionMs = visiblePosition.inMilliseconds
            .clamp(0, durationMs > 0 ? durationMs : 0)
            .toDouble();
        final canSeek = loaded && durationMs > 0;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 30,
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 3,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape: const RoundSliderOverlayShape(
                    overlayRadius: 14,
                  ),
                ),
                child: Slider(
                  min: 0,
                  max: durationMs > 0 ? durationMs.toDouble() : 1,
                  value: positionMs,
                  onChangeStart: canSeek
                      ? (value) => setState(
                            () => _dragPosition =
                                Duration(milliseconds: value.round()),
                          )
                      : null,
                  onChanged: canSeek
                      ? (value) => setState(
                            () => _dragPosition =
                                Duration(milliseconds: value.round()),
                          )
                      : null,
                  onChangeEnd: canSeek ? _seekTo : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(visiblePosition),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Text(
                    _formatDuration(duration),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpeedSelector(bool enabled) {
    final notifier = _speedNotifier!;
    return ValueListenableBuilder<double>(
      valueListenable: notifier,
      builder: (context, speed, _) => PopupMenuButton<double>(
        enabled: enabled,
        initialValue: speed,
        tooltip: '${speed.toStringAsFixed(1)}x',
        onSelected: (value) => notifier.value = value,
        itemBuilder: (context) => [
          for (final value in _playbackSpeeds)
            PopupMenuItem(
              value: value,
              child: Text('${value.toStringAsFixed(1)}x'),
            ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 10),
          child: Text(
            '${speed.toStringAsFixed(1)}x',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).disabledColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }

  Future<Duration?> _makeAudio(MatrixFile? file) async {
    if (file == null) {
      return null;
    }
    final info = EventScope.of(context).event.infoMap;
    final source = MatrixFileAudioSource(file);

    final duration = await player.setAudioSource(source, preload: true);
    await player.pause();
    await player.seek(Duration.zero);
    await player.setLoopMode(LoopMode.off);
    await player.setSpeed(_speedNotifier?.value ?? 1.0);
    final metadataDuration = info is Map
        ? Duration(milliseconds: (info['duration'] as num?)?.round() ?? 0)
        : Duration.zero;
    return duration ?? player.duration ?? metadataDuration;
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
    if (mounted && _playing != playerState.playing) {
      setState(() => _playing = playerState.playing);
    }
    switch (playerState.processingState) {
      case ProcessingState.idle:
      case ProcessingState.loading:
      case ProcessingState.buffering:
      case ProcessingState.ready:
        break;
      case ProcessingState.completed:
        await player.pause();
        await player.seek(Duration.zero);
        break;
    }
  }

  Future<void> _seekTo(double milliseconds) async {
    final target = Duration(milliseconds: milliseconds.round());
    try {
      await player.seek(target);
    } finally {
      if (mounted) setState(() => _dragPosition = null);
    }
  }

  void _applyPlaybackSpeed() {
    final speed = _speedNotifier?.value ?? 1.0;
    unawaited(
      player.setSpeed(speed).catchError((Object error, StackTrace stackTrace) {
        Logs().w('Unable to set audio playback speed.', error, stackTrace);
      }),
    );
  }

  String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.clamp(0, 359999).toInt();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    final minutesText =
        hours > 0 ? minutes.toString().padLeft(2, '0') : minutes.toString();
    final secondsText = seconds.toString().padLeft(2, '0');
    return hours > 0
        ? '$hours:$minutesText:$secondsText'
        : '$minutesText:$secondsText';
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
