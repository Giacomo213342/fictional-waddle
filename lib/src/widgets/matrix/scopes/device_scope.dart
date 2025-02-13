import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class DeviceScope extends InheritedWidget {
  const DeviceScope({
    super.key,
    required this.device,
    required super.child,
  });

  static DeviceScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DeviceScope>()!;
    return scope;
  }

  final Device device;

  @override
  bool updateShouldNotify(covariant DeviceScope oldWidget) =>
      device.displayName != oldWidget.device.displayName ||
      device.lastSeenIp != oldWidget.device.lastSeenIp ||
      device.lastSeenTs != oldWidget.device.lastSeenTs;
}
