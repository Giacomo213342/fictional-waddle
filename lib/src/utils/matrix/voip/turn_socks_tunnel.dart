import 'dart:async';
import 'dart:io';

import 'package:socks5_proxy/socks_client.dart';

import '../../../widgets/settings_manager.dart';

class TurnTcpEndpoint {
  const TurnTcpEndpoint({required this.host, required this.port});

  final String host;
  final int port;

  String get key => '$host:$port';
}

TurnTcpEndpoint? parseProxyableTurnTcpUrl(String value) {
  final separator = value.indexOf(':');
  if (separator <= 0 || value.substring(0, separator).toLowerCase() != 'turn') {
    return null;
  }
  final remainder = value.substring(separator + 1);
  final querySeparator = remainder.indexOf('?');
  final authority = querySeparator < 0
      ? remainder
      : remainder.substring(0, querySeparator);
  final query =
      querySeparator < 0 ? '' : remainder.substring(querySeparator + 1);
  if (Uri.splitQueryString(query)['transport']?.toLowerCase() != 'tcp') {
    return null;
  }

  try {
    final parsed = Uri.parse('tcp://$authority');
    if (parsed.host.isEmpty) return null;
    return TurnTcpEndpoint(
      host: parsed.host,
      port: parsed.hasPort ? parsed.port : 3478,
    );
  } on FormatException {
    return null;
  }
}

bool containsProxyableTurnTcpServer(Object? iceServers) {
  if (iceServers is! Iterable) return false;
  return iceServers.whereType<Map>().any((server) {
    final urls = server['urls'] ?? server['url'];
    final values = urls is Iterable ? urls : [urls];
    return values.whereType<String>().any(
          (url) => parseProxyableTurnTcpUrl(url) != null,
        );
  });
}

class TurnSocksTunnelPool {
  final Map<String, Future<_LocalTurnSocksTunnel>> _tunnels = {};
  final Set<Socket> _connections = {};
  String? _proxyFingerprint;

  Future<List<Map<String, dynamic>>> rewriteIceServers(
    Iterable<Map<String, dynamic>> iceServers,
    NetworkState network,
  ) async {
    final proxy = await _proxySettings(network);
    final fingerprint = '${proxy.host.address}:${proxy.port}:'
        '${network.proxyUsername ?? ''}:${network.proxyPassword ?? ''}';
    if (_proxyFingerprint != null && _proxyFingerprint != fingerprint) {
      await close();
    }
    _proxyFingerprint = fingerprint;

    final rewritten = <Map<String, dynamic>>[];
    for (final server in iceServers) {
      final rawUrls = server['urls'] ?? server['url'];
      final urls = rawUrls is Iterable ? rawUrls : [rawUrls];
      final localUrls = <String>[];
      for (final value in urls.whereType<String>()) {
        final endpoint = parseProxyableTurnTcpUrl(value);
        if (endpoint == null) continue;
        final tunnel = await (_tunnels[endpoint.key] ??=
            _LocalTurnSocksTunnel.start(
              endpoint: endpoint,
              proxy: proxy,
              connections: _connections,
            ));
        localUrls.add(
          'turn:127.0.0.1:${tunnel.localPort}?transport=tcp',
        );
      }
      if (localUrls.isNotEmpty) {
        rewritten.add({
          ...server,
          'urls': localUrls,
        }..remove('url'));
      }
    }
    return rewritten;
  }

  Future<ProxySettings> _proxySettings(NetworkState network) async {
    final host = network.proxyHost?.trim();
    final port = network.proxyPort;
    if (host == null || host.isEmpty || port == null) {
      throw StateError('SOCKS5 is enabled but its host or port is missing.');
    }
    var address = InternetAddress.tryParse(host);
    if (address == null) {
      final addresses = await InternetAddress.lookup(host);
      if (addresses.isEmpty) {
        throw StateError('Unable to resolve the SOCKS5 proxy.');
      }
      address = addresses.first;
    }
    return ProxySettings(
      address,
      port,
      username: network.proxyUsername ?? '',
      password: network.proxyPassword ?? '',
    );
  }

  Future<void> close() async {
    final tunnels = await Future.wait<Object?>(
      _tunnels.values.map((future) async {
        try {
          return await future;
        } catch (_) {
          return null;
        }
      }),
    );
    _tunnels.clear();
    for (final connection in _connections.toList()) {
      connection.destroy();
    }
    _connections.clear();
    for (final tunnel in tunnels.whereType<_LocalTurnSocksTunnel>()) {
      await tunnel.close();
    }
    _proxyFingerprint = null;
  }
}

class _LocalTurnSocksTunnel {
  _LocalTurnSocksTunnel._({
    required this.endpoint,
    required this.proxy,
    required this.server,
    required this.connections,
  });

  final TurnTcpEndpoint endpoint;
  final ProxySettings proxy;
  final ServerSocket server;
  final Set<Socket> connections;
  StreamSubscription<Socket>? _subscription;

  int get localPort => server.port;

  static Future<_LocalTurnSocksTunnel> start({
    required TurnTcpEndpoint endpoint,
    required ProxySettings proxy,
    required Set<Socket> connections,
  }) async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final tunnel = _LocalTurnSocksTunnel._(
      endpoint: endpoint,
      proxy: proxy,
      server: server,
      connections: connections,
    );
    tunnel._subscription = server.listen(
      (socket) => unawaited(tunnel._bridge(socket)),
    );
    return tunnel;
  }

  Future<void> _bridge(Socket local) async {
    connections.add(local);
    Socket? remote;
    try {
      remote = await SocksTCPClient.connect(
        [proxy],
        InternetAddress(endpoint.host, type: InternetAddressType.unix),
        endpoint.port,
      );
      connections.add(remote);
      await Future.any([
        local.cast<List<int>>().pipe(remote),
        remote.cast<List<int>>().pipe(local),
      ]);
    } catch (_) {
      // The peer connection reports transport failure through its ICE state.
    } finally {
      local.destroy();
      remote?.destroy();
      connections.remove(local);
      if (remote != null) connections.remove(remote);
    }
  }

  Future<void> close() async {
    await _subscription?.cancel();
    await server.close();
  }
}
