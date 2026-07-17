import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:polycule/src/utils/settings_interface.dart';
import 'package:polycule/src/widgets/settings_manager.dart';

void main() {
  test('call proxy preference participates in copy and equality', () {
    final original = NetworkState(
      useSocks5Proxy: true,
      proxyHost: '127.0.0.1',
      proxyPort: 1080,
    );
    final enabled = original.copyWith(proxyOneToOneCalls: true);

    expect(original.proxyOneToOneCalls, isFalse);
    expect(enabled.proxyOneToOneCalls, isTrue);
    expect(enabled.useSocks5Proxy, isTrue);
    expect(enabled.proxyHost, '127.0.0.1');
    expect(enabled.proxyPort, 1080);
    expect(enabled, isNot(original));
    expect(enabled, enabled.copyWith());
  });

  test('call proxy preference survives secure settings storage', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const settings = SettingsInterface();

    await settings.storeNetwork(
      NetworkState(
        useSocks5Proxy: true,
        proxyHost: 'proxy.example.org',
        proxyPort: 1080,
        proxyOneToOneCalls: true,
      ),
    );

    final restored = await settings.getNetwork();
    expect(restored.useSocks5Proxy, isTrue);
    expect(restored.proxyOneToOneCalls, isTrue);
    expect(restored.proxyHost, 'proxy.example.org');
    expect(restored.proxyPort, 1080);
  });
}
