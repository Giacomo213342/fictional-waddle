import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';

import '../../../widgets/settings_manager.dart';
import 'polycule_webrtc_delegate.dart';

class ActivePolyculeCall {
  const ActivePolyculeCall({required this.session, this.blockingError});

  final CallSession session;
  final String? blockingError;
}

class CallRelayUnavailableException implements Exception {
  const CallRelayUnavailableException();

  @override
  String toString() =>
      'The homeserver did not provide a TURN relay for proxy-only calls.';
}

class _ClientVoip {
  _ClientVoip({required this.voip, required this.delegate});

  final VoIP voip;
  final PolyculeWebRtcDelegate delegate;
}

class PolyculeCallCoordinator {
  final activeCall = ValueNotifier<ActivePolyculeCall?>(null);
  final Map<Client, _ClientVoip> _clients = {};
  ValueListenable<NetworkState>? _network;
  bool _startingCall = false;
  bool _missingTurnRelay = false;

  bool get canHandleNewCall => activeCall.value == null && !_startingCall;

  void attachNetwork(ValueListenable<NetworkState> network) {
    _network ??= network;
  }

  void registerClient(Client client) {
    if (_clients.containsKey(client)) {
      return;
    }
    final network = _network;
    if (network == null) {
      throw StateError('Network settings must be attached before Matrix VoIP.');
    }
    final delegate = PolyculeWebRtcDelegate(
      coordinator: this,
      network: network,
    );
    _clients[client] = _ClientVoip(
      voip: VoIP(client, delegate),
      delegate: delegate,
    );
  }

  Future<void> unregisterClient(Client client) async {
    final entry = _clients.remove(client);
    if (entry == null) {
      return;
    }
    final current = activeCall.value?.session;
    if (identical(current?.client, client) && !current!.callHasEnded) {
      await current.hangup(reason: CallErrorCode.userHangup);
    }
    entry.delegate.dispose();
  }

  Future<CallSession> startCall(Room room, CallType type) async {
    if (!canStartOneToOneCall(room)) {
      throw StateError('This room is not an available one-to-one chat.');
    }
    if (!canHandleNewCall) {
      throw StateError('Another call is already active.');
    }
    final entry = _clients[room.client];
    if (entry == null) {
      throw StateError('Calls are not initialized.');
    }

    _startingCall = true;
    _missingTurnRelay = false;
    try {
      final network = _network!.value;
      final relayOnly = network.useSocks5Proxy && network.proxyOneToOneCalls;
      if (relayOnly) {
        final iceServers = await entry.voip.getIceServers();
        if (!containsTurnServer(iceServers)) {
          throw const CallRelayUnavailableException();
        }
      }
      return await entry.voip.inviteToCall(
        room,
        type,
        userId: room.directChatMatrixID,
      );
    } finally {
      _startingCall = false;
    }
  }

  void noteMissingTurnRelay() {
    _missingTurnRelay = true;
  }

  void activate(CallSession session) {
    final error = _missingTurnRelay
        ? const CallRelayUnavailableException().toString()
        : null;
    _missingTurnRelay = false;
    activeCall.value = ActivePolyculeCall(
      session: session,
      blockingError: error,
    );
  }

  void deactivate(CallSession session) {
    if (identical(activeCall.value?.session, session)) {
      activeCall.value = null;
    }
  }

  Future<void> dispose() async {
    final current = activeCall.value?.session;
    if (current != null && !current.callHasEnded) {
      await current.hangup(reason: CallErrorCode.userHangup);
    }
    for (final entry in _clients.values) {
      entry.delegate.dispose();
    }
    _clients.clear();
    activeCall.dispose();
  }
}

bool canStartOneToOneCall(Room room) {
  return isOneToOneCallEligible(
    membership: room.membership,
    remoteUserId: room.directChatMatrixID,
    localUserId: room.client.userID,
    joinedMemberCount: room.summary.mJoinedMemberCount,
  );
}

bool isOneToOneCallEligible({
  required Membership membership,
  required String? remoteUserId,
  required String? localUserId,
  required int? joinedMemberCount,
}) =>
    membership == Membership.join &&
    remoteUserId != null &&
    remoteUserId != localUserId &&
    (joinedMemberCount == null || joinedMemberCount == 2);
