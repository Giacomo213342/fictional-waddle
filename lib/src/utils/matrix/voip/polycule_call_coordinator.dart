import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';

import '../../../widgets/settings_manager.dart';
import '../../../widgets/matrix/client_manager/client_store.dart';
import 'call_notification_manager.dart';
import 'polycule_voip.dart';
import 'polycule_webrtc_delegate.dart';
import 'turn_socks_tunnel.dart';

class ActivePolyculeCall {
  const ActivePolyculeCall({
    required this.session,
    this.blockingError,
    this.connectionStatus,
    this.visible = true,
  });

  final CallSession session;
  final String? blockingError;
  final String? connectionStatus;
  final bool visible;

  ActivePolyculeCall copyWith({
    String? blockingError,
    String? connectionStatus,
    bool? visible,
  }) =>
      ActivePolyculeCall(
        session: session,
        blockingError: blockingError ?? this.blockingError,
        connectionStatus: connectionStatus ?? this.connectionStatus,
        visible: visible ?? this.visible,
      );
}

class _CallConnectionSnapshot {
  const _CallConnectionSnapshot({
    required this.iceState,
    required this.peerState,
    required this.signalingState,
    required this.gatheringState,
    required this.hasLocalDescription,
    required this.hasRemoteDescription,
    required this.localCandidates,
    required this.remoteCandidates,
    required this.viableCandidatePairs,
  });

  final String iceState;
  final String peerState;
  final String signalingState;
  final String gatheringState;
  final bool hasLocalDescription;
  final bool hasRemoteDescription;
  final int localCandidates;
  final int remoteCandidates;
  final int viableCandidatePairs;

  String get compactLabel =>
      'ICE ${iceState.toUpperCase()} · $localCandidates↔$remoteCandidates';

  String get diagnosticKey => '$iceState|$peerState|$signalingState|'
      '$gatheringState|$hasLocalDescription|$hasRemoteDescription|'
      '$localCandidates|$remoteCandidates|$viableCandidatePairs';

  String timeoutMessage({required bool hasTurnRelay}) {
    if (!hasRemoteDescription) {
      return 'The remote call description was not applied.';
    }
    if (localCandidates == 0 || remoteCandidates == 0) {
      return 'No usable ICE candidates were exchanged.';
    }
    if (viableCandidatePairs == 0) {
      if (!hasTurnRelay) {
        return 'No reachable peer route was found. This network requires a '
            'homeserver TURN relay.';
      }
      return 'No reachable peer or TURN route was found.';
    }
    return 'Unable to establish the encrypted media connection (ICE).';
  }
}

class CallRelayUnavailableException implements Exception {
  const CallRelayUnavailableException();

  @override
  String toString() =>
      'The homeserver did not provide a TURN relay for proxy-only calls.';
}

class CallProxyTurnUnavailableException implements Exception {
  const CallProxyTurnUnavailableException();

  @override
  String toString() =>
      'The homeserver did not provide a TURN/TCP route usable through SOCKS5.';
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
  final Map<CallSession, Timer> _diagnosticTimers = {};
  final Map<CallSession, PeerConnectionConfiguration> _configurations = {};
  final Map<CallSession, _CallConnectionSnapshot> _diagnostics = {};
  final Set<CallSession> _samplingCalls = {};
  final Set<CallSession> _actionCalls = {};
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
      voip: PolyculeVoIP(client, delegate, network: network),
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
      await CallNotificationManager.requestFullScreenIntentPermission();
      final network = _network!.value;
      final relayOnly = network.useSocks5Proxy && network.proxyOneToOneCalls;
      if (relayOnly) {
        final iceServers = await entry.voip.getIceServers();
        if (!containsTurnServer(iceServers)) {
          throw const CallRelayUnavailableException();
        }
        if (!containsProxyableTurnTcpServer(iceServers)) {
          throw const CallProxyTurnUnavailableException();
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

  void attachPeerConnectionConfiguration(
    CallSession session,
    PeerConnectionConfiguration configuration,
  ) {
    _configurations[session] = configuration;
    Logs().i(
      '[VOIP] ICE configuration: servers=${configuration.iceServerCount}, '
      'turn=${configuration.turnServerCount}, '
      'fallbackStun=${configuration.usesFallbackStun}, '
      'relayOnly=${configuration.relayOnly}.',
    );
  }

  void activate(CallSession session) {
    final error = _missingTurnRelay
        ? const CallRelayUnavailableException().toString()
        : null;
    _missingTurnRelay = false;
    final awaitingAnswer = session.direction == CallDirection.kIncoming &&
        session.state == CallState.kRinging &&
        !session.answeredByUs;
    activeCall.value = ActivePolyculeCall(
      session: session,
      blockingError: error,
      visible: !awaitingAnswer || error != null,
    );
    unawaited(_showCallNotification(session));
    _handlePendingNotificationIntent();
  }

  void deactivate(CallSession session) {
    _connectionTimers.remove(session)?.cancel();
    _diagnosticTimers.remove(session)?.cancel();
    _configurations.remove(session);
    _diagnostics.remove(session);
    _samplingCalls.remove(session);
    _actionCalls.remove(session);
    unawaited(CallNotificationManager.cancel(session.callId));
    if (identical(activeCall.value?.session, session)) {
      activeCall.value = null;
    }
  }

  void minimizeActiveCall() {
    final current = activeCall.value;
    if (current == null || !current.visible) {
      return;
    }
    activeCall.value = current.copyWith(visible: false);
  }

  void showActiveCall() {
    final current = activeCall.value;
    if (current == null || current.visible) {
      return;
    }
    activeCall.value = current.copyWith(visible: true);
  }

  void callStateChanged(CallSession session) {
    final current = activeCall.value;
    if (!identical(current?.session, session)) {
      return;
    }
    activeCall.value = current!.copyWith();

    if (session.state == CallState.kConnected) {
      _connectionTimers.remove(session)?.cancel();
      _diagnosticTimers.remove(session)?.cancel();
      activeCall.value = current.copyWith(connectionStatus: 'ICE CONNECTED');
      unawaited(_showOngoingNotification(session, connected: true));
    } else if (session.state == CallState.kConnecting) {
      _startConnectionTimeout(session);
      _startConnectionDiagnostics(session);
      unawaited(_showOngoingNotification(session, connected: false));
    }
  }

  void _startConnectionDiagnostics(CallSession session) {
    if (_diagnosticTimers.containsKey(session)) {
      return;
    }
    unawaited(_sampleConnection(session));
    _diagnosticTimers[session] = Timer.periodic(
      const Duration(seconds: 2),
      (_) => unawaited(_sampleConnection(session)),
    );
  }

  Future<void> _sampleConnection(CallSession session) async {
    final pc = session.pc;
    if (pc == null || session.callHasEnded || !_samplingCalls.add(session)) {
      return;
    }
    try {
      final descriptions = await Future.wait([
        pc.getLocalDescription(),
        pc.getRemoteDescription(),
      ]);
      final stats = await pc.getStats();
      var localCandidates = 0;
      var remoteCandidates = 0;
      var viableCandidatePairs = 0;
      for (final report in stats) {
        switch (report.type) {
          case 'local-candidate':
            localCandidates++;
            break;
          case 'remote-candidate':
            remoteCandidates++;
            break;
          case 'candidate-pair':
            final state = report.values['state'];
            if (state == 'succeeded' || report.values['nominated'] == true) {
              viableCandidatePairs++;
            }
            break;
        }
      }
      final snapshot = _CallConnectionSnapshot(
        iceState: _shortRtcState(pc.iceConnectionState),
        peerState: _shortRtcState(pc.connectionState),
        signalingState: _shortRtcState(pc.signalingState),
        gatheringState: _shortRtcState(pc.iceGatheringState),
        hasLocalDescription: descriptions[0] != null,
        hasRemoteDescription: descriptions[1] != null,
        localCandidates: localCandidates,
        remoteCandidates: remoteCandidates,
        viableCandidatePairs: viableCandidatePairs,
      );
      final previous = _diagnostics[session];
      _diagnostics[session] = snapshot;
      if (previous?.diagnosticKey != snapshot.diagnosticKey) {
        Logs().i(
          '[VOIP] Connection diagnostics: ice=${snapshot.iceState}, '
          'peer=${snapshot.peerState}, signaling=${snapshot.signalingState}, '
          'gathering=${snapshot.gatheringState}, '
          'descriptions=${snapshot.hasLocalDescription}/'
          '${snapshot.hasRemoteDescription}, candidates='
          '${snapshot.localCandidates}/${snapshot.remoteCandidates}, '
          'viablePairs=${snapshot.viableCandidatePairs}.',
        );
        final current = activeCall.value;
        if (identical(current?.session, session)) {
          activeCall.value = current!.copyWith(
            connectionStatus: snapshot.compactLabel,
          );
        }
      }
    } catch (error, stackTrace) {
      Logs().w(
        '[VOIP] Unable to sample peer connection state.',
        error,
        stackTrace,
      );
    } finally {
      _samplingCalls.remove(session);
    }
  }

  void _startConnectionTimeout(CallSession session) {
    if (_connectionTimers.containsKey(session)) {
      return;
    }
    _connectionTimers[session] = Timer(const Duration(seconds: 35), () {
      if (session.callHasEnded || session.state == CallState.kConnected) {
        _connectionTimers.remove(session);
        return;
      }
      final current = activeCall.value;
      if (identical(current?.session, session)) {
        activeCall.value = ActivePolyculeCall(
          session: session,
          blockingError: _diagnostics[session]?.timeoutMessage(
                hasTurnRelay:
                    (_configurations[session]?.turnServerCount ?? 0) > 0,
              ) ??
              'Unable to establish the encrypted media connection (ICE).',
          connectionStatus: current?.connectionStatus,
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

  String peerName(CallSession session) => _peerName(session);

  bool isAwaitingAnswer(CallSession session) =>
      session.direction == CallDirection.kIncoming &&
      session.state == CallState.kRinging &&
      !session.answeredByUs;

  Future<void> answerActiveCall() async {
    final session = activeCall.value?.session;
    if (session == null ||
        !isAwaitingAnswer(session) ||
        !_actionCalls.add(session)) {
      return;
    }
    try {
      showActiveCall();
      await _answerFromNotification(session);
    } catch (error, stackTrace) {
      _showActionError(session, error, stackTrace);
    } finally {
      _actionCalls.remove(session);
    }
  }

  Future<void> declineActiveCall() async {
    final session = activeCall.value?.session;
    if (session == null ||
        !isAwaitingAnswer(session) ||
        !_actionCalls.add(session)) {
      return;
    }
    try {
      await session.reject(reason: CallErrorCode.userHangup);
    } catch (error, stackTrace) {
      _showActionError(session, error, stackTrace);
    } finally {
      _actionCalls.remove(session);
    }
  }

  Future<void> hangupActiveCall() async {
    final session = activeCall.value?.session;
    if (session == null || !_actionCalls.add(session)) {
      return;
    }
    try {
      await _hangup(session);
    } finally {
      _actionCalls.remove(session);
    }
  }

  void _showActionError(
    CallSession session,
    Object error,
    StackTrace stackTrace,
  ) {
    Logs().w('[VOIP] Incoming call action failed.', error, stackTrace);
    final current = activeCall.value;
    if (identical(current?.session, session)) {
      activeCall.value = ActivePolyculeCall(
        session: session,
        blockingError: 'Call action failed. Check the application logs.',
        connectionStatus: current?.connectionStatus,
        visible: true,
      );
    }
  }

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
    switch (intent.action) {
      case CallNotificationAction.show:
        showActiveCall();
        return;
      case CallNotificationAction.answer:
        unawaited(answerActiveCall());
        break;
      case CallNotificationAction.decline:
        unawaited(declineActiveCall());
        break;
      case CallNotificationAction.hangup:
        unawaited(_hangup(session));
        break;
    }
  }

  Future<void> _hangup(CallSession session) async {
    try {
      await session.hangup(reason: CallErrorCode.userHangup);
    } catch (error, stackTrace) {
      _showActionError(session, error, stackTrace);
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
    for (final timer in _diagnosticTimers.values) {
      timer.cancel();
    }
    _diagnosticTimers.clear();
    _configurations.clear();
    _diagnostics.clear();
    _samplingCalls.clear();
    _actionCalls.clear();
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

String _shortRtcState(Object? state) {
  if (state == null) {
    return 'unknown';
  }
  var value = state.toString().split('.').last;
  for (final prefix in const [
    'RTCIceConnectionState',
    'RTCPeerConnectionState',
    'RTCSignalingState',
    'RTCIceGatheringState',
  ]) {
    if (value.startsWith(prefix)) {
      value = value.substring(prefix.length);
      break;
    }
  }
  return value.toLowerCase();
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
