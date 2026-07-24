import 'package:flutter_test/flutter_test.dart';

import 'package:matrix/matrix.dart';
import 'package:polycule/src/utils/matrix/room_last_event_loader.dart';

class _NoopDatabase implements DatabaseApi {
  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late Client client;

  setUp(() {
    client = Client('polycule_client_1', database: _NoopDatabase());
  });

  tearDown(() => client.dispose());

  test('cached encrypted last event is replaced after background decryption',
      () async {
    final room = Room(id: '!room:example.org', client: client);
    final timestamp = DateTime.utc(2026, 7, 24);
    final encrypted = Event(
      content: const {'algorithm': 'm.megolm.v1.aes-sha2'},
      type: EventTypes.Encrypted,
      eventId: r'$event',
      senderId: '@alice:example.org',
      originServerTs: timestamp,
      room: room,
    );
    final decrypted = Event(
      content: const {
        'msgtype': MessageTypes.Text,
        'body': 'Latest readable message',
      },
      type: EventTypes.Message,
      eventId: encrypted.eventId,
      senderId: encrypted.senderId,
      originServerTs: timestamp,
      room: room,
    );
    room.lastEvent = encrypted;

    final loaded = await RoomLastEventLoader.load(
      room,
      decrypt: (_) async => decrypted,
    );

    expect(loaded, same(decrypted));
    expect(room.lastEvent, same(decrypted));
    expect(room.lastEvent?.body, 'Latest readable message');
  });

  test('a failed decryption keeps the latest encrypted event available',
      () async {
    final room = Room(id: '!room:example.org', client: client);
    final encrypted = Event(
      content: const {'algorithm': 'm.megolm.v1.aes-sha2'},
      type: EventTypes.Encrypted,
      eventId: r'$event',
      senderId: '@alice:example.org',
      originServerTs: DateTime.utc(2026, 7, 24),
      room: room,
    );
    room.lastEvent = encrypted;

    final loaded = await RoomLastEventLoader.load(
      room,
      decrypt: (_) async => throw StateError('missing session'),
    );

    expect(loaded, same(encrypted));
    expect(room.lastEvent, same(encrypted));
  });
}
