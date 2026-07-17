import 'package:matrix/matrix.dart';

enum MatrixCallLifecycleKind { invite, answer, reject, hangup }

MatrixCallLifecycleKind? matrixCallLifecycleKind(String type) {
  if (!isMatrixCallSignalingEventType(type)) {
    return null;
  }
  if (type.endsWith('.invite')) {
    return MatrixCallLifecycleKind.invite;
  }
  if (type.endsWith('.answer')) {
    return MatrixCallLifecycleKind.answer;
  }
  if (type.endsWith('.reject')) {
    return MatrixCallLifecycleKind.reject;
  }
  if (type.endsWith('.hangup')) {
    return MatrixCallLifecycleKind.hangup;
  }
  return null;
}

bool isMatrixCallSignalingEventType(String type) =>
    type.startsWith('m.call.') || type.startsWith('org.matrix.call.');

bool callInviteContainsVideo(Map<String, dynamic> content) {
  final metadata = content['org.matrix.msc3077.sdp_stream_metadata'] ??
      content['sdp_stream_metadata'];
  if (metadata is Map) {
    for (final value in metadata.values) {
      if (value is Map && value['video_muted'] == false) {
        return true;
      }
    }
  }
  final offer = content['offer'];
  final sdp = offer is Map ? offer['sdp'] : null;
  return sdp is String && RegExp(r'(^|\r?\n)m=video\s').hasMatch(sdp);
}

String matrixCallEventSummary(
  Event event, {
  required String senderName,
  Timeline? timeline,
}) {
  final kind = matrixCallLifecycleKind(event.type);
  final own = event.senderId == event.room.client.userID;
  final actor = own ? 'You' : senderName;
  final callType = _callTypeFor(event, timeline);
  final duration = _callDuration(event, timeline);
  final suffix = duration == null ? '' : ' · ${_formatDuration(duration)}';

  return switch (kind) {
    MatrixCallLifecycleKind.invite => '$actor started a $callType call',
    MatrixCallLifecycleKind.answer => '$actor answered the call',
    MatrixCallLifecycleKind.reject => '$actor declined the call',
    MatrixCallLifecycleKind.hangup => '${_hangupSummary(event, actor)}$suffix',
    null => 'Call activity',
  };
}

String _callTypeFor(Event event, Timeline? timeline) {
  Event? invite;
  if (matrixCallLifecycleKind(event.type) == MatrixCallLifecycleKind.invite) {
    invite = event;
  } else {
    final callId = event.content['call_id'];
    if (callId is String && timeline != null) {
      for (final candidate in timeline.events) {
        if (matrixCallLifecycleKind(candidate.type) ==
                MatrixCallLifecycleKind.invite &&
            candidate.content['call_id'] == callId) {
          invite = candidate;
          break;
        }
      }
    }
  }
  return invite != null && callInviteContainsVideo(invite.content)
      ? 'video'
      : 'voice';
}

Duration? _callDuration(Event event, Timeline? timeline) {
  final kind = matrixCallLifecycleKind(event.type);
  if (timeline == null ||
      (kind != MatrixCallLifecycleKind.hangup &&
          kind != MatrixCallLifecycleKind.reject)) {
    return null;
  }
  final callId = event.content['call_id'];
  if (callId is! String) {
    return null;
  }
  Event? start;
  for (final candidate in timeline.events) {
    if (candidate.content['call_id'] != callId) {
      continue;
    }
    final candidateKind = matrixCallLifecycleKind(candidate.type);
    if (candidateKind == MatrixCallLifecycleKind.answer) {
      start = candidate;
      break;
    }
    if (candidateKind == MatrixCallLifecycleKind.invite) {
      start ??= candidate;
    }
  }
  if (start == null || !event.originServerTs.isAfter(start.originServerTs)) {
    return null;
  }
  return event.originServerTs.difference(start.originServerTs);
}

String _hangupSummary(Event event, String actor) {
  return switch (event.content['reason']) {
    'invite_timeout' => 'Missed call',
    'user_busy' => '$actor was busy',
    'ice_failed' => 'Call ended · connection failed',
    _ => '$actor ended the call',
  };
}

String _formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);
  if (hours > 0) {
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }
  if (minutes > 0) {
    return '${minutes}m ${seconds.toString().padLeft(2, '0')}s';
  }
  return '${seconds}s';
}
