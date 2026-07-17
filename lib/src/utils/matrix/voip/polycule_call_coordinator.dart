import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';

import '../../../widgets/settings_manager.dart';
import 'call_notification_manager.dart';
import 'polycule_webrtc_delegate.dart';

class ActivePolyculeCall {
  const ActivePolyculeCall({
    required this.session,
    this.blockingError,
    this.visible = true,
  });

  final CallSession session;
  final String? blockingError;
  final bool visible;

  ActivePolyculeCall copyWith({
    String? blockingError,
    bool? visible,
  }) =>
      ActivePolyculeCall(
        session: session,
        blockingError: blockingError ?? this.blockingError,
        visible: visible ?? this.visible,
      );
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
  PolyculeCallCoordinator() {
    CallNotificationManager.pendingIntent.addListener(
      _handlePendingNotificationIntent,
    );
  }

  final activeCall = ValueNotifier<ActivePolyculeCall?>(null);
  final Map<Client, _ClientVoip> _clients = {};
  final Map<CallSession, Timer> _connectionTimers = {};
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
    unawaited(_showCallNotification(session));
    _handlePendingNotificationIntent();
  }

  void deactivate(CallSession session) {
    _connectionTimers.remove(session)?.cancel();
    unawaited(CallNotificationManager.cancel(session.callId));
    if (identical(activeCall.value?.session, session)) {
      activeCall.value = null;
    }
  }

  void minimizeActiveCall() {
    final current = activeCall.value;
    if (current == null || !current.visible) return;
    activeCall.value = current.copyWith(visible: false);
  }

  void showActiveCall() {
    final current = activeCall.value;
    if (current == null || current.visible) return;
    activeCall.value = current.copyWith(visible: true);
  }

  void callStateChanged(CallSession session) {
    final current = activeCall.value;
    if (!identical(current?.session, session)) return;
    activeCall.value = current!.copyWith();

    if (session.state == CallState.kConnected) {
      _connectionTimers.remove(session)?.cancel();
      unawaited(_showOngoingNotification(session, connected: true));
    } else if (session.state == CallState.kConnecting) {
      _startConnectionTimeout(session);
      unawaited(_showOngoingNotification(session, connected: false));
    }
  }

  void _startConnectionTimeout(CallSession session) {
    if (_connectionTimers.containsKey(session)) return;
    _connectionTimers[session] = Timer(const Duration(seconds: 35), () {
      if (session.callHasEnded || session.state == CallState.kConnected) {
        _connectionTimers.remove(session);
        return;
      }
      final current = activeCall.value;
      if (identical(current?.session, session)) {
        activeCall.value = ActivePolyculeCall(
          session: session,
          blockingError:
              'Unable to establish the encrypted media connection (ICE).',
          visible: true,
        );
      }
      _connectionTimers[session] = Timer(const Duration(seconds: 5), () {
        _connectionTimers.remove(session);
        if (!session.callHasEnded && session.state != CallState.kConnected) {
          unawaited(session.hangup(reason: CallErrorCode.iceFailed));
        }
      });
    });
  }

  Future<void> _showCallNotification(CallSession session) {
    if (session.direction == CallDirection.kIncoming &&
        session.state == CallState.kRinging &&
        !session.answeredByUs) {
      return CallNotificationManager.showIncoming(
        clientIdentifier: session.client.clientName.clientIdentifier,
        roomId: session.room.id,
        callId: session.callId,
        callerName: _peerName(session),
        video: session.type == CallType.kVideo,
        timeout: const Duration(minutes: 1),
      );
    }
    return _showOngoingNotification(
      session,
      connected: session.state == CallState.kConnected,
    );
  }

  Future<void> _showOngoingNotification(
    CallSession session, {
    required bool connected,
  }) =>
      CallNotificationManager.showOngoing(
        clientIdentifier: session.client.clientName.clientIdentifier,
        roomId: session.room.id,
        callId: session.callId,
        peerName: _peerName(session),
        connected: connected,
      );

  String _peerName(CallSession session) =>
      session.remoteUser?.calcDisplayname() ??
      session.remoteUserId ??
      'Matrix call';

  void _handlePendingNotificationIntent() {
    final intent = CallNotificationManager.pendingIntent.value;
    final current = activeCall.value;
    final session = current?.session;
    if (intent == null ||
        session == null ||
        intent.callId != session.callId ||
        intent.clientIdentifier != session.client.clientName.clientIdentifier) {
      return;
    }
    CallNotificationManager.clearPending(intent);
    showActiveCall();
    switch (intent.action) {
      case CallNotificationAction.show:
        return;
      case CallNotificationAction.answer:
        unawaited(_answerFromNotification(session));
        break;
      case CallNotificationAction.decline:
        unawaited(
          session.reject(reason: CallErrorCode.userHangup),
        );
        break;
      case CallNotificationAction.hangup:
        unawaited(session.hangup(reason: CallErrorCode.userHangup));
        break;
    }
  }

  Future<void> _answerFromNotification(CallSession session) async {
    await _showOngoingNotification(session, connected: false);
    await session.answer();
  }

  Future<void> dispose() async {
    CallNotificationManager.pendingIntent.removeListener(
      _handlePendingNotificationIntent,
    );
    for (final timer in _connectionTimers.values) {
      timer.cancel();
    }
    _connectionTimers.clear();
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
