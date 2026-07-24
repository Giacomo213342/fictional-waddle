import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:polycule/src/pages/room/components/membership/join.dart';

class _NoopDatabase implements DatabaseApi {
  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('latest shortcut follows distance from reversed-list origin', () {
    expect(
      shouldShowLatestMessagesShortcut(
        pixels: 150,
        viewportDimension: 800,
      ),
      isFalse,
    );
    expect(
      shouldShowLatestMessagesShortcut(
        pixels: 540,
        viewportDimension: 800,
      ),
      isTrue,
    );
  });

  test('loaded event offset is estimated in both timeline directions', () {
    expect(
      estimateReversedTimelineOffset(
        eventIndex: 0,
        eventCount: 101,
        maxScrollExtent: 10000,
      ),
      0,
    );
    expect(
      estimateReversedTimelineOffset(
        eventIndex: 25,
        eventCount: 101,
        maxScrollExtent: 10000,
      ),
      2500,
    );
    expect(
      estimateReversedTimelineOffset(
        eventIndex: 100,
        eventCount: 101,
        maxScrollExtent: 10000,
      ),
      10000,
    );
  });

  test('initial cached-history reveal stays deliberately tiny', () {
    expect(initialHistoryRevealDuration, const Duration(milliseconds: 80));
    expect(initialHistoryRevealDelay(1), const Duration(milliseconds: 10));
    expect(initialHistoryRevealDelay(100), const Duration(milliseconds: 80));
  });

  test('unread divider sits slightly above the viewport midpoint', () {
    expect(initialUnreadMarkerAlignment, greaterThan(.4));
    expect(initialUnreadMarkerAlignment, lessThan(.5));
  });

  test('unread boundary skips own messages sent after the receipt', () async {
    final client = Client('polycule_client_1', database: _NoopDatabase());
    final room = Room(id: '!room:example.org', client: client);
    final events = [
      _message(room, r'$newest', '@other:example.org', 4),
      _message(room, r'$mine', '@me:example.org', 3),
      _message(room, r'$read', '@other:example.org', 2),
      _message(room, r'$old', '@other:example.org', 1),
    ];
    addTearDown(client.dispose);

    final boundary = resolveUnreadBoundaryEventId(
      events,
      r'$read',
      '@me:example.org',
    );

    expect(boundary, r'$mine');
    expect(firstUnreadDisplayEventId(events, boundary), r'$newest');
  });

  test('first unread ignores non-display timeline events', () async {
    final client = Client('polycule_client_1', database: _NoopDatabase());
    final room = Room(id: '!room:example.org', client: client);
    final events = [
      _message(room, r'$visible', '@other:example.org', 3),
      Event(
        content: const {
          'm.relates_to': {
            'rel_type': 'm.annotation',
            'event_id': r'$read',
            'key': '👍',
          },
        },
        type: EventTypes.Reaction,
        eventId: r'$reaction',
        senderId: '@other:example.org',
        originServerTs: DateTime.fromMillisecondsSinceEpoch(2),
        room: room,
      ),
      _message(room, r'$read', '@other:example.org', 1),
    ];
    addTearDown(client.dispose);

    expect(firstUnreadDisplayEventId(events, r'$read'), r'$visible');
  });
}

Event _message(Room room, String eventId, String senderId, int timestamp) =>
    Event(
      content: const {
        'msgtype': MessageTypes.Text,
        'body': 'message',
      },
      type: EventTypes.Message,
      eventId: eventId,
      senderId: senderId,
      originServerTs: DateTime.fromMillisecondsSinceEpoch(timestamp),
      room: room,
    );
