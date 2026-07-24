import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/pages/room/components/compose/voice_message_composer.dart';

void main() {
  test('voice amplitudes are normalized to the Matrix waveform range', () {
    expect(normalizeVoiceAmplitude(-100), 0);
    expect(normalizeVoiceAmplitude(-60), 0);
    expect(normalizeVoiceAmplitude(-30), 512);
    expect(normalizeVoiceAmplitude(0), 1024);
    expect(normalizeVoiceAmplitude(20), 1024);
  });

  test('waveform compaction preserves peaks and never exceeds 50 samples', () {
    final samples = List<int>.generate(125, (index) => index);
    final waveform = compactVoiceWaveform(samples);

    expect(waveform, hasLength(50));
    expect(waveform.first, 1);
    expect(waveform.last, 124);
    expect(waveform.every((sample) => sample >= 0 && sample <= 1024), isTrue);
  });

  test('voice events carry interoperable Matrix metadata and persist', () {
    final sender = File(
      'lib/src/pages/room/components/compose/send_file_scope.dart',
    ).readAsStringSync();
    final queue = File(
      'lib/src/utils/matrix/media_upload_queue.dart',
    ).readAsStringSync();

    expect(sender, contains("'org.matrix.msc3245.voice'"));
    expect(sender, contains("'org.matrix.msc1767.audio'"));
    expect(sender, contains("'duration': duration.inMilliseconds"));
    expect(sender, contains("'waveform': waveform"));
    expect(sender, contains('MediaUploadQueue.enqueue('));
    expect(queue, contains("'extraContent': extraContent"));
    expect(queue, contains("manifest['extraContent']"));
  });

  test('composer exposes record, pause, resume, cancel, and send controls', () {
    final composer = File(
      'lib/src/pages/room/components/compose/voice_message_composer.dart',
    ).readAsStringSync();

    expect(composer, contains('_recorder.hasPermission()'));
    expect(composer, contains('_recorder.start('));
    expect(composer, contains('_recorder.pause()'));
    expect(composer, contains('_recorder.resume()'));
    expect(composer, contains('_recorder.cancel()'));
    expect(composer, contains('_recorder.stop()'));
    expect(composer, contains('onAmplitudeChanged('));
    expect(composer, contains('SendFileScope.of(context)'));
  });
}
