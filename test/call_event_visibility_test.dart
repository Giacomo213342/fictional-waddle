import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/call_event_summary.dart';

void main() {
  test('recognizes legacy Matrix call signaling families', () {
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

  test('only call lifecycle milestones have timeline summaries', () {
    expect(
      matrixCallLifecycleKind('m.call.invite'),
      MatrixCallLifecycleKind.invite,
    );
    expect(
      matrixCallLifecycleKind('org.matrix.call.answer'),
      MatrixCallLifecycleKind.answer,
    );
    expect(
      matrixCallLifecycleKind('m.call.reject'),
      MatrixCallLifecycleKind.reject,
    );
    expect(
      matrixCallLifecycleKind('m.call.hangup'),
      MatrixCallLifecycleKind.hangup,
    );
    for (final type in [
      'm.call.candidates',
      'm.call.negotiate',
      'm.call.select_answer',
      'org.matrix.call.sdp_stream_metadata_changed',
    ]) {
      expect(matrixCallLifecycleKind(type), isNull, reason: type);
    }
  });

  test('detects video without exposing SDP', () {
    expect(
      callInviteContainsVideo({
        'offer': {'sdp': 'v=0\r\nm=audio 9 RTP\r\nm=video 9 RTP'},
      }),
      isTrue,
    );
    expect(
      callInviteContainsVideo({
        'offer': {'sdp': 'v=0\r\nm=audio 9 RTP'},
      }),
      isFalse,
    );
  });

  test('room messages and MatrixRTC membership are not call signaling', () {
    expect(isMatrixCallSignalingEventType('m.room.message'), isFalse);
    expect(isMatrixCallSignalingEventType('m.call.member'), isTrue);
    expect(isMatrixCallSignalingEventType('org.matrix.msc3401.call'), isFalse);
  });
}
