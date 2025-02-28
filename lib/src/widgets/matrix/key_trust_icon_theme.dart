import 'package:flutter/material.dart';

import '../../theme/colors/poly_pride.dart';
import 'scopes/client_scope.dart';
import 'scopes/device_scope.dart';

class KeyTrustIconTheme extends StatelessWidget {
  const KeyTrustIconTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final device = DeviceScope.of(context).device;

    // TODO: support future user scope
    final userId = client.userID;

    final deviceKeys =
        client.userDeviceKeys[userId]?.deviceKeys[device.deviceId];

    Color? color;

    if (deviceKeys == null) {
      color = null;
    } else if (deviceKeys.blocked) {
      color = Theme.of(context).colorScheme.error;
    } else if (deviceKeys.verified) {
      color = PolyColors.cyan;
    } else {
      final isOwnDevice = client.userDeviceKeys[client.userID]?.deviceKeys
          .containsKey(device.deviceId);
      if (isOwnDevice ?? false) {
        color = Theme.of(context).colorScheme.error;
      } else {
        color = null;
      }
    }
    return IconTheme(
      data: IconTheme.of(context).copyWith(color: color),
      child: child,
    );
  }
}
