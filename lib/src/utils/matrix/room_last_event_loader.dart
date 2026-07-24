import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'package:matrix/matrix.dart';

typedef RoomEventDecryptor = Future<Event> Function(Event event);
typedef RoomLastEventHistoryLoader = Future<Event?> Function(
  Room room,
  Event expected,
);

final class RoomLastEventLoader {
  const RoomLastEventLoader._();

  static final Map<String, ValueNotifier<int>> _revisions = {};
  static final Map<String, Future<Event?>> _inFlight = {};
  static final Map<String, Room> _watchedRooms = {};
  static final Map<String, StreamSubscription<String>>
      _sessionKeySubscriptions = {};

  static ValueNotifier<int> _revisionNotifierFor(Room room) =>
      _revisions.putIfAbsent(_roomKey(room), () => ValueNotifier<int>(0));

  static ValueListenable<int> revisionFor(Room room) =>
      _revisionNotifierFor(room);

  static String _roomKey(Room room) =>
      '${room.client.clientName}\u0000${room.id}';

  static Future<Event?> load(
    Room room, {
    RoomEventDecryptor? decrypt,
    RoomLastEventHistoryLoader? loadFromHistory,
  }) {
    final event = room.lastEvent;
    if (event == null || event.type != EventTypes.Encrypted) {
      return Future.value(event);
    }
    _watchForSessionKeys(room);

    final encryption = room.client.encryption;
    final decryptEvent = decrypt ??
        (encryption == null
            ? null
            : (Event event) => encryption.decryptRoomEvent(
                  event,
                  store: true,
                  updateType: EventUpdateType.history,
                ));
    if (decryptEvent == null) {
      return Future.value(event);
    }

    final key =
        '${room.client.clientName}\u0000${room.id}\u0000${event.eventId}';
    return _inFlight.putIfAbsent(key, () async {
      Event decrypted = event;
      try {
        final originalSource = event.originalSource;
        final decryptCandidate = originalSource == null
            ? event
            : Event.fromMatrixEvent(originalSource, room);
        decrypted = await decryptEvent(decryptCandidate);
      } catch (error, stackTrace) {
        Logs().d(
          'Unable to decrypt the last event for ${room.id}.',
          error,
          stackTrace,
        );
      }

      if (decrypted.type == EventTypes.Encrypted) {
        try {
          decrypted =
              await (loadFromHistory ?? _loadFromHistory)(room, event) ??
                  decrypted;
        } catch (error, stackTrace) {
          Logs().d(
            'Unable to load the cached last event for ${room.id}.',
            error,
            stackTrace,
          );
        }
      }

      final current = room.lastEvent;
      if (current?.eventId != event.eventId) {
        return current;
      }
      if (current?.type != EventTypes.Encrypted) {
        return current;
      }
      if (decrypted.type != EventTypes.Encrypted) {
        room.lastEvent = decrypted;
        _revisionNotifierFor(room).value++;
      }
      return decrypted;
    }).whenComplete(() {
      _inFlight.remove(key);
    });
  }

  static Future<Event?> _loadFromHistory(Room room, Event expected) async {
    final timeline = await room.getTimeline(limit: 1);
    try {
      for (final event in timeline.events) {
        if (event.eventId == expected.eventId) {
          return event;
        }
      }
      return null;
    } finally {
      timeline.cancelSubscriptions();
    }
  }

  static void _watchForSessionKeys(Room room) {
    final key = _roomKey(room);
    if (identical(_watchedRooms[key], room)) {
      return;
    }
    unawaited(_sessionKeySubscriptions.remove(key)?.cancel());
    _watchedRooms[key] = room;
    _sessionKeySubscriptions[key] =
        room.onSessionKeyReceived.stream.listen((_) {
      if (!identical(_watchedRooms[key], room) ||
          room.lastEvent?.type != EventTypes.Encrypted) {
        return;
      }
      // Loading a room timeline requests missing Megolm sessions. Retry the
      // preview as soon as that key arrives instead of requiring the user to
      // open the conversation before its last message becomes readable.
      unawaited(load(room));
    });
  }

  static Future<void> disposeClient(Client client) async {
    final keys = _watchedRooms.entries
        .where((entry) => identical(entry.value.client, client))
        .map((entry) => entry.key)
        .toList(growable: false);
    for (final key in keys) {
      _watchedRooms.remove(key);
      await _sessionKeySubscriptions.remove(key)?.cancel();
      _revisions.remove(key)?.dispose();
    }
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
