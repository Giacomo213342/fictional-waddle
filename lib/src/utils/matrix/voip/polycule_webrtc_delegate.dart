import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:matrix/matrix.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../widgets/settings_manager.dart';
import 'polycule_call_coordinator.dart';

class PeerConnectionConfiguration {
  const PeerConnectionConfiguration({
    required this.value,
    required this.relayUnavailable,
  });

  final Map<String, dynamic> value;
  final bool relayUnavailable;
}

PeerConnectionConfiguration configurePeerConnection(
  Map<String, dynamic> source, {
  required bool relayOnly,
}) {
  final configuration = Map<String, dynamic>.from(source);
  if (!relayOnly) {
    return PeerConnectionConfiguration(
      value: configuration,
      relayUnavailable: false,
    );
  }

  configuration['iceTransportPolicy'] = 'relay';
  return PeerConnectionConfiguration(
    value: configuration,
    relayUnavailable: !containsTurnServer(configuration['iceServers']),
  );
}

bool containsTurnServer(Object? iceServers) {
  if (iceServers is! Iterable) {
    return false;
  }
  for (final server in iceServers) {
    if (server is! Map) {
      continue;
    }
    final urls = server['urls'] ?? server['url'];
    final candidates = urls is Iterable ? urls : [urls];
    if (candidates.whereType<String>().any(
          (url) => url.startsWith('turn:') || url.startsWith('turns:'),
        )) {
      return true;
    }
  }
  return false;
}

class PolyculeWebRtcDelegate implements WebRTCDelegate {
  PolyculeWebRtcDelegate({
    required this.coordinator,
    required this.network,
  });

  final PolyculeCallCoordinator coordinator;
  final ValueListenable<NetworkState> network;
  Timer? _ringtoneTimer;

  bool get _relayOnly {
    final state = network.value;
    return state.useSocks5Proxy && state.proxyOneToOneCalls;
  }

  @override
  MediaDevices get mediaDevices => webrtc.navigator.mediaDevices;

  @override
  Future<RTCPeerConnection> createPeerConnection(
    Map<String, dynamic> configuration, [
    Map<String, dynamic> constraints = const {},
  ]) {
    final configured = configurePeerConnection(
      configuration,
      relayOnly: _relayOnly,
    );
    if (configured.relayUnavailable) {
      coordinator.noteMissingTurnRelay();
    }
    return webrtc.createPeerConnection(configured.value, constraints);
  }

  @override
  Future<void> playRingtone() async {
    await stopRingtone();
    await SystemSound.play(SystemSoundType.alert);
    _ringtoneTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      unawaited(SystemSound.play(SystemSoundType.alert));
    });
  }

  @override
  Future<void> stopRingtone() async {
    _ringtoneTimer?.cancel();
    _ringtoneTimer = null;
  }

  @override
  Future<void> registerListeners(CallSession session) async {}

  @override
  Future<void> handleNewCall(CallSession session) async {
    coordinator.activate(session);
  }

  @override
  Future<void> handleCallEnded(CallSession session) async {
    await stopRingtone();
    coordinator.deactivate(session);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await webrtc.Helper.clearAndroidCommunicationDevice();
      } catch (error, stackTrace) {
        Logs().w(
          'Unable to clear Android call audio routing.',
          error,
          stackTrace,
        );
      }
    }
  }

  @override
  Future<void> handleMissedCall(CallSession session) async {
    await stopRingtone();
    Logs().i('Missed 1:1 call ${session.callId} in ${session.room.id}.');
  }

  @override
  Future<void> handleNewGroupCall(GroupCallSession groupCall) async {}

  @override
  Future<void> handleGroupCallEnded(GroupCallSession groupCall) async {}

  @override
  bool get isWeb => kIsWeb;

  @override
  bool get canHandleNewCall => coordinator.canHandleNewCall;

  @override
  EncryptionKeyProvider? get keyProvider => null;

  void dispose() {
    _ringtoneTimer?.cancel();
    _ringtoneTimer = null;
  }
}
