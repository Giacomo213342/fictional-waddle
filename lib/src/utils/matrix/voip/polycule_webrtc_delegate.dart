import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as webrtc;
import 'package:matrix/matrix.dart';
import 'package:webrtc_interface/webrtc_interface.dart';

import '../../../widgets/settings_manager.dart';
import 'polycule_call_coordinator.dart';
import 'turn_socks_tunnel.dart';

class PeerConnectionConfiguration {
  const PeerConnectionConfiguration({
    required this.value,
    required this.relayUnavailable,
    required this.iceServerCount,
    required this.turnServerCount,
    required this.usesFallbackStun,
    required this.relayOnly,
  });

  final Map<String, dynamic> value;
  final bool relayUnavailable;
  final int iceServerCount;
  final int turnServerCount;
  final bool usesFallbackStun;
  final bool relayOnly;
}

const matrixFallbackStunServer = 'stun:turn.matrix.org';

PeerConnectionConfiguration configurePeerConnection(
  Map<String, dynamic> source, {
  required bool relayOnly,
}) {
  final configuration = Map<String, dynamic>.from(source);
  final sourceServers = configuration['iceServers'];
  final iceServers = sourceServers is Iterable
      ? sourceServers.whereType<Map>().map(Map<String, dynamic>.from).toList()
      : <Map<String, dynamic>>[];
  var usesFallbackStun = false;

  // This opt-in fallback matches matrix-js-sdk. Host-only candidates cannot
  // normally cross mobile or residential NAT, while STUN keeps media P2P.
  // Relay-only calls deliberately never use a direct/STUN fallback.
  if (!relayOnly && !iceServers.any(_isStunServer)) {
    iceServers.add(const {
      'urls': [matrixFallbackStunServer],
    });
    usesFallbackStun = true;
  }

  configuration['iceServers'] = iceServers;
  if (relayOnly) {
    configuration['iceTransportPolicy'] = 'relay';
  }
  final turnServerCount = iceServers.where(_isTurnServer).length;
  return PeerConnectionConfiguration(
    value: configuration,
    relayUnavailable: relayOnly && turnServerCount == 0,
    iceServerCount: iceServers.length,
    turnServerCount: turnServerCount,
    usesFallbackStun: usesFallbackStun,
    relayOnly: relayOnly,
  );
}

bool _isTurnServer(Map<dynamic, dynamic> server) {
  final urls = server['urls'] ?? server['url'];
  final candidates = urls is Iterable ? urls : [urls];
  return candidates.whereType<String>().any(
        (url) => url.startsWith('turn:') || url.startsWith('turns:'),
      );
}

bool _isStunServer(Map<dynamic, dynamic> server) {
  final urls = server['urls'] ?? server['url'];
  final candidates = urls is Iterable ? urls : [urls];
  return candidates.whereType<String>().any(
        (url) => url.startsWith('stun:') || url.startsWith('stuns:'),
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
    if (_isTurnServer(server)) {
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
  final Map<CallSession, List<StreamSubscription<dynamic>>> _callSubscriptions =
      {};
  PeerConnectionConfiguration? _pendingConfiguration;
  Timer? _ringtoneTimer;
  final TurnSocksTunnelPool _turnSocksTunnels = TurnSocksTunnelPool();

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
  ]) async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await webrtc.Helper.setAndroidAudioConfiguration(
        webrtc.AndroidAudioConfiguration.communication,
      );
    }
    var configured = configurePeerConnection(
      configuration,
      relayOnly: _relayOnly,
    );
    if (_relayOnly && !configured.relayUnavailable) {
      final sourceServers = configured.value['iceServers'] as Iterable;
      final rewritten = await _turnSocksTunnels.rewriteIceServers(
        sourceServers.whereType<Map>().map(Map<String, dynamic>.from),
        network.value,
      );
      configured = PeerConnectionConfiguration(
        value: {
          ...configured.value,
          'iceServers': rewritten,
        },
        relayUnavailable: rewritten.isEmpty,
        iceServerCount: rewritten.length,
        turnServerCount: rewritten.length,
        usesFallbackStun: false,
        relayOnly: true,
      );
    }
    _pendingConfiguration = configured;
    if (configured.relayUnavailable) {
      coordinator.noteMissingTurnRelay();
    }
    return webrtc.createPeerConnection(configured.value, constraints);
  }

  @override
  Future<void> playRingtone() async {
    await stopRingtone();
    // Android ringing belongs to the native incoming-call notification. A
    // repeated SystemSound is the notification beep, not the device ringtone.
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return;
    }
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
  Future<void> registerListeners(CallSession session) async {
    if (_callSubscriptions.containsKey(session)) {
      return;
    }
    final configuration = _pendingConfiguration;
    _pendingConfiguration = null;
    if (configuration != null) {
      coordinator.attachPeerConnectionConfiguration(session, configuration);
    }
    _callSubscriptions[session] = [
      session.onCallStateChanged.stream.listen((_) {
        coordinator.callStateChanged(session);
      }),
      session.onCallEventChanged.stream.listen((_) {
        coordinator.callStateChanged(session);
      }),
    ];
  }

  @override
  Future<void> handleNewCall(CallSession session) async {
    coordinator.activate(session);
  }

  @override
  Future<void> handleCallEnded(CallSession session) async {
    final subscriptions = _callSubscriptions.remove(session) ?? const [];
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
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
    unawaited(_turnSocksTunnels.close());
    for (final subscriptions in _callSubscriptions.values) {
      for (final subscription in subscriptions) {
        unawaited(subscription.cancel());
      }
    }
    _callSubscriptions.clear();
    _ringtoneTimer?.cancel();
    _ringtoneTimer = null;
  }
}
