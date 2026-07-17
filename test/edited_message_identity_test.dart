import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:matrix/src/models/timeline_chunk.dart';
import 'package:polycule/src/utils/matrix/is_display_event_extension.dart';
import 'package:polycule/src/utils/matrix/neighboaring_event_extension.dart';
import 'package:polycule/src/utils/matrix/polycule_display_event_extension.dart';

class _NoopDatabase implements DatabaseApi {
  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late Client client;
  late Timeline timeline;

  setUp(() {
    client = Client('polycule_client_1', database: _NoopDatabase());
  });

  tearDown(() async {
    timeline.cancelSubscriptions();
    await client.dispose();
  });

  test('replacement content retains the original timeline identity', () {
    final room = Room(id: '!room:example.org', client: client);
    final originalTime = DateTime.utc(2026, 7, 17, 10);
    final original = Event(
      content: const {
        'msgtype': MessageTypes.Text,
        'body': 'before',
        'm.relates_to': {
          'm.in_reply_to': {'event_id': r'$quoted'},
        },
      },
      type: EventTypes.Message,
      eventId: r'$original',
      senderId: '@alice:example.org',
      originServerTs: originalTime,
      room: room,
    );
    final edit = Event(
      content: const {
        'msgtype': MessageTypes.Text,
        'body': '* after',
        'm.new_content': {
          'msgtype': MessageTypes.Text,
          'body': 'after',
        },
        'm.relates_to': {
          'rel_type': RelationshipTypes.edit,
          'event_id': r'$original',
        },
      },
      type: EventTypes.Message,
      eventId: r'$edit',
      senderId: '@alice:example.org',
      originServerTs: originalTime.add(const Duration(minutes: 20)),
      room: room,
    );
    timeline = Timeline(
      room: room,
      chunk: TimelineChunk(events: [edit, original]),
    );

    final resolved = original.resolvePolyculeDisplayEvent(timeline);

    expect(resolved.isEdited, isTrue);
    expect(resolved.event.body, 'after');
    expect(resolved.event.eventId, original.eventId);
    expect(resolved.event.originServerTs, originalTime);
    expect(resolved.event.relationshipType, RelationshipTypes.reply);
    expect(resolved.event.relationshipEventId, r'$quoted');
    expect(timeline.indexOfLogicalEvent(resolved.event), 1);
    expect(edit.shouldDisplayEvent, isFalse);
  });
}
