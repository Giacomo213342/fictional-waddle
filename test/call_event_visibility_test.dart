import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/is_display_event_extension.dart';

void main() {
  test('all legacy Matrix call signaling families are hidden', () {
    for (final type in [
      'm.call.invite',
      'm.call.answer',
      'm.call.candidates',
      'm.call.negotiate',
      'm.call.select_answer',
      'm.call.hangup',
      'org.matrix.call.sdp_stream_metadata_changed',
    ]) {
      expect(isMatrixCallSignalingEventType(type), isTrue, reason: type);
    }
  });

  test('room messages and MatrixRTC membership are not call signaling', () {
    expect(isMatrixCallSignalingEventType('m.room.message'), isFalse);
    expect(isMatrixCallSignalingEventType('m.call.member'), isTrue);
    expect(isMatrixCallSignalingEventType('org.matrix.msc3401.call'), isFalse);
  });
}
