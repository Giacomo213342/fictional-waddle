import 'package:flutter/services.dart';

/// Native Android call notification bridge.
abstract final class PolyculeCallNotifications {
  static const channel = MethodChannel('polycule.calls');
}
