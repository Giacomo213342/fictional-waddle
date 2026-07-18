import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matrix/matrix.dart';

import '../../../widgets/settings_manager.dart';
import 'call_log_journal.dart';

typedef TurnCredentialsLoader = Future<TurnServerCredentials> Function();

/// Refreshes expiring TURN credentials without exposing their contents.
class TurnCredentialCache {
  TurnCredentialCache({
    required TurnCredentialsLoader load,
    DateTime Function()? now,
  })  : _load = load,
        _now = now ?? DateTime.now;

  final TurnCredentialsLoader _load;
  final DateTime Function() _now;
  TurnServerCredentials? _credentials;
  DateTime? _refreshAt;
  Future<TurnServerCredentials>? _inFlight;

  Future<TurnServerCredentials> resolve() {
    final cached = _credentials;
    final refreshAt = _refreshAt;
    if (cached != null && refreshAt != null && _now().isBefore(refreshAt)) {
      return Future.value(cached);
    }

    final inFlight = _inFlight;
    if (inFlight != null) {
      return inFlight;
    }
    final request = _loadAndCache();
    _inFlight = request;
    return request.whenComplete(() {
      if (identical(_inFlight, request)) {
        _inFlight = null;
      }
    });
  }

  Future<TurnServerCredentials> _loadAndCache() async {
    final credentials = await _load();
    final ttl = credentials.ttl < 0 ? 0 : credentials.ttl;
    // Refresh before expiry. Short-lived credentials retain 90% of their TTL;
    // longer leases keep a fixed 30-second safety margin.
    final safetySeconds = ttl > 300 ? 30 : (ttl / 10).ceil();
    final usableSeconds = ttl - safetySeconds;
    _credentials = credentials;
    _refreshAt = _now().add(
      Duration(seconds: usableSeconds > 0 ? usableSeconds : 0),
    );
    return credentials;
  }
}

class PolyculeVoIP extends VoIP {
  PolyculeVoIP(
    super.client,
    super.delegate, {
    required ValueListenable<NetworkState> network,
  }) : _turnCredentials = TurnCredentialCache(
          load: () async {
            final relayOnly = network.value.useSocks5Proxy &&
                network.value.proxyOneToOneCalls;
            await CallLogJournal.record(
              'Requesting homeserver TURN credentials through the Matrix '
              'HTTP client (SOCKS5=${network.value.useSocks5Proxy}, '
              'relayOnly=$relayOnly).',
            );
            return client.getTurnServer().timeout(
                  const Duration(seconds: 8),
                  onTimeout: () => throw TimeoutException(
                    'Matrix TURN credential lookup timed out.',
                  ),
                );
          },
        );

  final TurnCredentialCache _turnCredentials;

  /// Claims the conference before mesh setup so matching peer invites are not
  /// rejected by the SDK's busy guard during [GroupCallSession.enter].
  void claimGroupCall(String roomId, String callId) {
    for (final id in groupCalls.keys) {
      if (id.roomId == roomId && id.callId == callId) {
        currentGroupCID = id;
        return;
      }
    }
    throw StateError('The group call must be registered before it is claimed.');
  }

  bool isClaimedGroupCall(String roomId, String callId) =>
      currentGroupCID?.roomId == roomId && currentGroupCID?.callId == callId;

  void releaseClaimedGroupCall(String roomId, String callId) {
    if (isClaimedGroupCall(roomId, callId)) {
      currentGroupCID = null;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getIceServers() async {
    try {
      final credentials = await _turnCredentials.resolve();
      if (credentials.uris.isEmpty) {
        await CallLogJournal.record(
          'Homeserver TURN lookup returned incomplete credentials.',
          level: Level.warning,
        );
        return const [];
      }
      await CallLogJournal.record(
        'Homeserver TURN lookup succeeded: '
        '${credentials.uris.length} ICE URI(s), ttl=${credentials.ttl}s.',
        important: true,
      );
      return [
        {
          'username': credentials.username,
          'credential': credentials.password,
          'urls': credentials.uris,
        },
      ];
    } catch (error) {
      final description = error is MatrixException
          ? '${error.errcode}, HTTP ${error.response?.statusCode ?? 'unknown'}'
          : error.runtimeType.toString();
      await CallLogJournal.record(
        'Homeserver TURN lookup failed ($description).',
        level: Level.warning,
      );
      return const [];
    }
  }
}
