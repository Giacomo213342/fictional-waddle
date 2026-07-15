import 'package:flutter/widgets.dart';

/// Tracks the room currently visible in the foreground isolate.
class ActiveRoomTracker {
  ActiveRoomTracker._();

  static String? roomId;
  static AppLifecycleState lifecycleState = AppLifecycleState.resumed;

  static bool isVisible(String id) =>
      roomId == id && lifecycleState == AppLifecycleState.resumed;
}
