import 'package:matrix/matrix.dart';

typedef RoomListResetCallback = void Function();

/// Keeps room-list navigation behavior stable across the responsive shell.
class RoomListPositionTracker {
  RoomListPositionTracker._();

  static final Map<String, RoomListResetCallback> _resetCallbacks = {};
  static final Set<String> _interactedClients = {};

  static void register(String clientName, RoomListResetCallback callback) {
    _resetCallbacks[clientName] = callback;
  }

  static void unregister(String clientName, RoomListResetCallback callback) {
    if (_resetCallbacks[clientName] == callback) {
      _resetCallbacks.remove(clientName);
    }
  }

  static void markInteraction(Room room) {
    _interactedClients.add(room.client.clientName);
  }

  static void prepareReturn(Room room) {
    final clientName = room.client.clientName;
    if (_interactedClients.remove(clientName)) {
      _resetCallbacks[clientName]?.call();
    }
  }
}
