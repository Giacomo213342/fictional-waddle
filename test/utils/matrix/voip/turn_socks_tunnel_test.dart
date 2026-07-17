import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/voip/turn_socks_tunnel.dart';
import 'package:polycule/src/widgets/settings_manager.dart';
import 'package:socks5_proxy/socks_server.dart';

void main() {
  test('recognizes only plaintext TURN over TCP', () {
    final endpoint = parseProxyableTurnTcpUrl(
      'turn:21334.mooo.com:3478?transport=tcp',
    );
    expect(endpoint?.host, '21334.mooo.com');
    expect(endpoint?.port, 3478);
    expect(
      parseProxyableTurnTcpUrl('turn:21334.mooo.com:3478?transport=udp'),
      isNull,
    );
    expect(
      parseProxyableTurnTcpUrl('turns:21334.mooo.com:5349?transport=tcp'),
      isNull,
    );
  });

  test('rewrites and forwards TURN TCP through authenticated SOCKS5', () async {
    final target = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final targetSubscription = target.listen((socket) {
      socket.listen(socket.add, onDone: socket.destroy);
    });
    final proxy = SocksServer(
      authHandler: (username, password) =>
          username == 'polycule' && password == 'secret',
    );
    await proxy.bind(InternetAddress.loopbackIPv4, 0);
    final proxyPort = proxy.proxies.keys.single;
    final pool = TurnSocksTunnelPool();
    addTearDown(() async {
      await pool.close();
      await proxy.stop();
      await targetSubscription.cancel();
      await target.close();
    });

    final rewritten = await pool.rewriteIceServers(
      [
        {
          'username': 'turn-user',
          'credential': 'turn-password',
          'urls': [
            'turn:127.0.0.1:${target.port}?transport=udp',
            'turn:127.0.0.1:${target.port}?transport=tcp',
          ],
        },
      ],
      NetworkState(
        useSocks5Proxy: true,
        proxyHost: '127.0.0.1',
        proxyPort: proxyPort,
        proxyUsername: 'polycule',
        proxyPassword: 'secret',
        proxyOneToOneCalls: true,
      ),
    );

    expect(rewritten, hasLength(1));
    expect(rewritten.single['username'], 'turn-user');
    expect(rewritten.single['credential'], 'turn-password');
    final localUrl = (rewritten.single['urls'] as List<String>).single;
    final localEndpoint = parseProxyableTurnTcpUrl(localUrl)!;
    expect(localEndpoint.host, '127.0.0.1');

    final client = await Socket.connect(localEndpoint.host, localEndpoint.port);
    addTearDown(client.destroy);
    client.add(const [1, 3, 3, 7]);
    await client.flush();
    expect(await client.first.timeout(const Duration(seconds: 2)), [1, 3, 3, 7]);
  });
}
