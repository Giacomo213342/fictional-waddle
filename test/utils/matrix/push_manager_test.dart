import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:polycule/src/utils/matrix/push_manager.dart';

void main() {
  Pusher pusher(String appId, String pushKey) => Pusher(
        appId: appId,
        pushkey: pushKey,
        appDisplayName: 'Polycule',
        data: PusherData(url: Uri.parse('https://push.invalid')),
        deviceDisplayName: 'Device',
        kind: 'http',
        lang: 'en',
      );

  test('only stale endpoints belonging to the same device are removed', () {
    const currentApp = 'business.braid.polycule.DEVICE';
    final current = pusher(currentApp, 'https://push.invalid/current');
    final stale = pusher(currentApp, 'https://push.invalid/stale');
    final otherDevice = pusher(
      'business.braid.polycule.OTHER',
      'https://push.invalid/other',
    );

    expect(
      staleDevicePushers(
        [current, stale, otherDevice],
        appId: currentApp,
        activePushKey: current.pushkey,
      ),
      [same(stale)],
    );
  });
}
