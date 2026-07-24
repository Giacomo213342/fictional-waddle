import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import 'send_file_scope.dart';

typedef VoiceComposerBuilder = Widget Function(
  BuildContext context,
  VoidCallback startRecording,
);

int normalizeVoiceAmplitude(double decibels) {
  final normalized = ((decibels.clamp(-60, 0) + 60) / 60) * 1024;
  return normalized.round().clamp(0, 1024);
}

List<int> compactVoiceWaveform(List<int> samples, {int maximumLength = 50}) {
  if (samples.length <= maximumLength) {
    return List.unmodifiable(samples);
  }
  return List<int>.generate(
    maximumLength,
    (index) {
      final start = index * samples.length ~/ maximumLength;
      final end = (index + 1) * samples.length ~/ maximumLength;
      return samples.sublist(start, max(start + 1, end)).reduce(max);
    },
    growable: false,
  );
}

class VoiceMessageComposer extends StatefulWidget {
  const VoiceMessageComposer({super.key, required this.builder});

  final VoiceComposerBuilder builder;

  @override
  State<VoiceMessageComposer> createState() => _VoiceMessageComposerState();
}

class _VoiceMessageComposerState extends State<VoiceMessageComposer> {
  final AudioRecorder _recorder = AudioRecorder();
  final Stopwatch _duration = Stopwatch();
  final List<int> _waveform = [];

  StreamSubscription<Amplitude>? _amplitudeSubscription;
  Timer? _timer;
  bool _recording = false;
  bool _paused = false;
  bool _busy = false;

  @override
  void dispose() {
    _timer?.cancel();
    _amplitudeSubscription?.cancel();
    unawaited(_disposeRecorder());
    super.dispose();
  }

  Future<void> _disposeRecorder() async {
    if (_recording) {
      await _recorder.cancel();
    }
    await _recorder.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_recording) {
      return widget.builder(context, () => unawaited(_startRecording()));
    }
    return Semantics(
      liveRegion: true,
      label: 'Recording voice message',
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              tooltip: AppLocalizations.of(context).cancel,
              onPressed: _busy ? null : () => unawaited(_cancelRecording()),
              icon: const Icon(Icons.delete_outline),
            ),
            IconButton(
              tooltip: _paused ? 'Resume recording' : 'Pause recording',
              onPressed: _busy ? null : () => unawaited(_togglePaused()),
              icon: Icon(
                _paused ? Icons.mic_rounded : Icons.pause_rounded,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    size: 12,
                    color: _paused
                        ? Theme.of(context).colorScheme.outline
                        : Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(_formatDuration(_duration.elapsed)),
                ],
              ),
            ),
            Expanded(
              child: CustomPaint(
                painter: _VoiceWaveformPainter(
                  samples: List.unmodifiable(_waveform),
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: const SizedBox.expand(),
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox.square(
                  dimension: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              IconButton.filled(
                tooltip: AppLocalizations.of(context).send,
                onPressed: () => unawaited(_sendRecording()),
                icon: const Icon(Icons.send_rounded),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRecording() async {
    if (_busy || _recording) {
      return;
    }
    _busy = true;
    try {
      if (!await _recorder.hasPermission()) {
        _showError('Microphone permission is required for voice messages.');
        return;
      }
      final temporaryDirectory = await getTemporaryDirectory();
      final path =
          '${temporaryDirectory.path}/voice-${DateTime.now().microsecondsSinceEpoch}.m4a';
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 48000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: path,
      );
      _waveform.clear();
      _duration
        ..reset()
        ..start();
      _amplitudeSubscription = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen(_recordAmplitude);
      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (mounted) {
          setState(() {});
        }
      });
      if (mounted) {
        setState(() {
          _recording = true;
          _paused = false;
        });
      }
    } catch (error, stackTrace) {
      Logs().e('Unable to start voice recording.', error, stackTrace);
      _showError('Unable to start the voice recording.');
    } finally {
      _busy = false;
    }
  }

  void _recordAmplitude(Amplitude amplitude) {
    if (!mounted || _paused) {
      return;
    }
    setState(() {
      _waveform.add(normalizeVoiceAmplitude(amplitude.current));
    });
  }

  Future<void> _togglePaused() async {
    if (_paused) {
      await _recorder.resume();
      _duration.start();
    } else {
      await _recorder.pause();
      _duration.stop();
    }
    if (mounted) {
      setState(() => _paused = !_paused);
    }
  }

  Future<void> _cancelRecording() async {
    _busy = true;
    _stopUiTimers();
    try {
      await _recorder.cancel();
    } catch (error, stackTrace) {
      Logs().w('Unable to cancel voice recording.', error, stackTrace);
    } finally {
      if (mounted) {
        setState(() {
          _recording = false;
          _paused = false;
          _busy = false;
        });
      }
    }
  }

  Future<void> _sendRecording() async {
    _busy = true;
    _duration.stop();
    final recordedDuration = _duration.elapsed;
    _stopUiTimers();
    try {
      final path = await _recorder.stop();
      if (path == null) {
        throw StateError('The recorder returned no output file.');
      }
      final recording = File(path);
      final bytes = await recording.readAsBytes();
      await recording.delete().catchError((_) => recording);
      if (!mounted) {
        return;
      }
      final sender = SendFileScope.of(context);
      final file = MatrixAudioFile(
        bytes: bytes,
        name: 'Voice message.m4a',
        mimeType: 'audio/mp4',
        duration: recordedDuration.inMilliseconds,
      );
      final waveform = compactVoiceWaveform(
        _waveform.isEmpty ? const [0] : _waveform,
      );
      unawaited(
        sender
            .sendVoiceMessage(
          file: file,
          duration: recordedDuration,
          waveform: waveform,
        )
            .catchError((Object error, StackTrace stackTrace) {
          Logs().e('Unable to send voice message.', error, stackTrace);
          _showError('Unable to send the voice message.');
        }),
      );
      setState(() {
        _recording = false;
        _paused = false;
      });
    } catch (error, stackTrace) {
      Logs().e('Unable to finish voice recording.', error, stackTrace);
      _showError('Unable to finish the voice recording.');
      if (mounted) {
        setState(() {
          _recording = false;
          _paused = false;
        });
      }
    } finally {
      _busy = false;
    }
  }

  void _stopUiTimers() {
    _duration.stop();
    _timer?.cancel();
    _timer = null;
    unawaited(_amplitudeSubscription?.cancel());
    _amplitudeSubscription = null;
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class _VoiceWaveformPainter extends CustomPainter {
  const _VoiceWaveformPainter({required this.samples, required this.color});

  final List<int> samples;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final visibleBars = max(1, (size.width / 5).floor());
    final visibleSamples = samples.length > visibleBars
        ? samples.sublist(samples.length - visibleBars)
        : samples;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;
    for (var index = 0; index < visibleSamples.length; index++) {
      final amplitude = visibleSamples[index] / 1024;
      final barHeight = 4 + amplitude * max(0, size.height - 12);
      final x = size.width -
          (visibleSamples.length - index) * (size.width / visibleBars) +
          2;
      canvas.drawLine(
        Offset(x, (size.height - barHeight) / 2),
        Offset(x, (size.height + barHeight) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceWaveformPainter oldDelegate) =>
      oldDelegate.samples.length != samples.length ||
      oldDelegate.color != color;
}
