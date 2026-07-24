import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

typedef RoomEventDecryptor = Future<Event> Function(Event event);

final class RoomLastEventLoader {
  const RoomLastEventLoader._();

  static final Map<String, ValueNotifier<int>> _revisions = {};
  static final Map<String, Future<Event?>> _inFlight = {};

  static ValueNotifier<int> _revisionNotifierFor(Room room) =>
      _revisions.putIfAbsent(_roomKey(room), () => ValueNotifier<int>(0));

  static ValueListenable<int> revisionFor(Room room) =>
      _revisionNotifierFor(room);

  static String _roomKey(Room room) =>
      '${room.client.clientName}\u0000${room.id}';

  static Future<Event?> load(
    Room room, {
    RoomEventDecryptor? decrypt,
  }) {
    final event = room.lastEvent;
    if (event == null || event.type != EventTypes.Encrypted) {
      return Future.value(event);
    }

    final encryption = room.client.encryption;
    final decryptEvent = decrypt ?? encryption?.decryptRoomEvent;
    if (decryptEvent == null) {
      return Future.value(event);
    }

    final key =
        '${room.client.clientName}\u0000${room.id}\u0000${event.eventId}';
    return _inFlight.putIfAbsent(key, () async {
      try {
        final decrypted = await decryptEvent(event);
        if (decrypted.type != EventTypes.Encrypted &&
            room.lastEvent?.eventId == event.eventId) {
          room.lastEvent = decrypted;
          _revisionNotifierFor(room).value++;
        }
        return decrypted;
      } catch (error, stackTrace) {
        Logs().d(
          'Unable to decrypt the last event for ${room.id}.',
          error,
          stackTrace,
        );
        return event;
      } finally {
        _inFlight.remove(key);
      }
    });
  }

  static Future<void> warmClient(
    Client client, {
    int maxConcurrent = 4,
  }) async {
    await client.accountDataLoading;
    await client.roomsLoading;
    final rooms = client.rooms
        .where((room) => room.membership == Membership.join)
        .toList();
    if (rooms.isEmpty) {
      return;
    }

    var nextRoom = 0;
    Future<void> worker() async {
      while (nextRoom < rooms.length) {
        final room = rooms[nextRoom++];
        await load(room);
      }
    }

    await Future.wait(
      List.generate(min(maxConcurrent, rooms.length), (_) => worker()),
    );
  }
}
