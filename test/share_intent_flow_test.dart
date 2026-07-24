import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:polycule/src/pages/share_target/share_target.dart';
import 'package:polycule/src/widgets/intent_manager.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

class _NoopDatabase implements DatabaseApi {
  @override
  Future<void> close() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  test('shared files retain MIME type and accompanying text atomically', () {
    final payload = sharedIntentPayloadFromFiles(
      [
        SharedMediaFile(
          path: '/tmp/photo.jpg',
          type: SharedMediaType.image,
          mimeType: 'image/jpeg',
          message: 'caption',
        ),
        SharedMediaFile(
          path: 'https://example.org',
          type: SharedMediaType.url,
        ),
      ],
      id: 7,
    );

    expect(payload, isNotNull);
    expect(payload!.id, 7);
    expect(payload.files, hasLength(1));
    expect(payload.files.single.mimeType, 'image/jpeg');
    expect(payload.text, 'caption\nhttps://example.org');
  });

  test('destination changes keep the same payload identity', () {
    const payload = SharedIntentPayload(
      id: 11,
      files: [],
      text: 'hello',
    );

    final selected = payload.copyWithDestination(
      clientName: 'polycule_client_2',
      roomId: '!room:example.org',
    );
    final cleared = selected.copyWithDestination();

    expect(selected.id, payload.id);
    expect(selected.text, payload.text);
    expect(selected.clientName, 'polycule_client_2');
    expect(selected.roomId, '!room:example.org');
    expect(cleared.clientName, isNull);
    expect(cleared.roomId, isNull);
  });

  test('identical initial and stream deliveries have one fingerprint', () {
    final files = [
      SharedMediaFile(
        path: '/tmp/video.mp4',
        type: SharedMediaType.video,
        mimeType: 'video/mp4',
      ),
    ];

    expect(
      shareIntentFingerprint(files),
      shareIntentFingerprint(List.of(files)),
    );
    expect(
      shareIntentFingerprint(files),
      isNot(
        shareIntentFingerprint([
          SharedMediaFile(
            path: '/tmp/video.mp4',
            type: SharedMediaType.video,
            mimeType: 'video/webm',
          ),
        ]),
      ),
    );
  });

  test('share picker only includes joined non-space rooms and filters by id',
      () async {
    final client = Client('polycule_client_1', database: _NoopDatabase());
    final joined = Room(id: '!joined:example.org', client: client);
    final invited = Room(
      id: '!invited:example.org',
      client: client,
      membership: Membership.invite,
    );
    final left = Room(
      id: '!left:example.org',
      client: client,
      membership: Membership.leave,
    );
    client.rooms.addAll([joined, invited, left]);
    addTearDown(client.dispose);

    expect(
      shareTargets([client]).map((target) => target.room.id),
      ['!joined:example.org'],
    );
    expect(
      shareTargets([client], query: 'JOINED').single.room,
      same(joined),
    );
    expect(shareTargets([client], query: 'missing'), isEmpty);
  });

  test('share picker keeps low-priority rooms below normal rooms', () async {
    final client = Client('polycule_client_1', database: _NoopDatabase());
    final lowPriority = Room(
      id: '!low:example.org',
      client: client,
      roomAccountData: {
        'm.tag': BasicEvent(
          type: 'm.tag',
          content: {
            'tags': {TagType.lowPriority: <String, dynamic>{}},
          },
        ),
      },
    );
    final normal = Room(id: '!normal:example.org', client: client);
    lowPriority.lastEvent = Event(
      content: const {'msgtype': MessageTypes.Text, 'body': 'new'},
      type: EventTypes.Message,
      eventId: r'$low',
      senderId: '@alice:example.org',
      originServerTs: DateTime.utc(2026, 7, 24, 12),
      room: lowPriority,
    );
    normal.lastEvent = Event(
      content: const {'msgtype': MessageTypes.Text, 'body': 'older'},
      type: EventTypes.Message,
      eventId: r'$normal',
      senderId: '@alice:example.org',
      originServerTs: DateTime.utc(2026, 7, 24, 11),
      room: normal,
    );
    client.rooms.addAll([lowPriority, normal]);
    addTearDown(client.dispose);

    expect(
      shareTargets([client]).map((target) => target.room.id),
      ['!normal:example.org', '!low:example.org'],
    );
  });

  test('share route and send scope enforce explicit room selection', () {
    final router = File('lib/src/router/router.dart').readAsStringSync();
    final application = File('lib/src/polycule.dart').readAsStringSync();
    final intentManager =
        File('lib/src/widgets/intent_manager.dart').readAsStringSync();
    final sender = File(
      'lib/src/pages/room/components/compose/send_file_scope.dart',
    ).readAsStringSync();

    expect(router, contains('path: ShareTargetPage.routeName'));
    expect(application, contains('IntentManager.attachNavigation(router!.go)'));
    expect(intentManager, isNot(contains('context.go(')));
    expect(intentManager, contains('_navigateTo(ShareTargetPage.routeName)'));
    expect(intentManager, contains('if (clientsReady.value)'));
    expect(intentManager, contains('clientsReady.addListener(listener)'));
    expect(intentManager, contains('_cancelPendingShareNavigation()'));
    expect(intentManager, contains("'consumeShareIntent'"));
    expect(intentManager, contains("'cancelShareIntent'"));
    final shareTarget =
        File('lib/src/pages/share_target/share_target.dart').readAsStringSync();
    expect(shareTarget, contains('closeExternalTask: true'));
    final mainActivity = File(
      'android/app/src/main/kotlin/business/braid/polycule/MainActivity.kt',
    ).readAsStringSync();
    expect(
      mainActivity,
      contains('Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS'),
    );
    expect(mainActivity, contains('finishAndRemoveTask()'));
    expect(
      mainActivity,
      contains('currentIntent.action = Intent.ACTION_MAIN'),
    );
    expect(
      shareTarget,
      contains('ProfileAvatarBuilder('),
    );
    expect(sender, contains('payload.clientName != room.client.clientName'));
    expect(sender, contains('payload.roomId != room.id'));
    expect(sender, contains('final selector = FileSelector(null)'));
    expect(sender, contains("context.go('/share')"));
  });
}
