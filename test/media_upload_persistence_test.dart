import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('media bytes and transaction metadata are durable before upload', () {
    final queue = File(
      'lib/src/utils/matrix/media_upload_queue.dart',
    ).readAsStringSync();
    final sender = File(
      'lib/src/pages/room/components/compose/send_file_scope.dart',
    ).readAsStringSync();

    expect(queue, contains('writeAsBytes(file.bytes, flush: true)'));
    expect(queue, contains('writeAsString(jsonEncode(manifest), flush: true)'));
    expect(
      queue,
      contains("temporary.rename('\${directory.path}/\$_manifestName')"),
    );
    expect(queue, contains("'txid': txid"));
    expect(queue, contains('txid: txid'));
    expect(
      sender.indexOf('MediaUploadQueue.enqueue('),
      lessThan(sender.indexOf('room.sendFileEvent(')),
    );
    expect(sender, contains('final replyEvent = compose.replyEvent;'));
    expect(sender, contains('final editEvent = compose.editEvent;'));
  });

  test('Android retries each upload as unique network-constrained work', () {
    final worker = File(
      'android/app/src/main/kotlin/business/braid/polycule/'
      'MediaUploadWorker.kt',
    ).readAsStringSync();

    expect(worker, contains('NetworkType.CONNECTED'));
    expect(worker, contains('enqueueUniqueWork('));
    expect(worker, contains('ExistingWorkPolicy.KEEP'));
    expect(worker, contains('setBackoffCriteria('));
    expect(worker, contains('Result.retry()'));
    expect(worker, contains('listOf(MEDIA_WORKER_ARGUMENT, jobId)'));
  });

  test('headless upload engine cannot hijack UnifiedPush callbacks', () {
    final worker = File(
      'android/app/src/main/kotlin/business/braid/polycule/'
      'MediaUploadWorker.kt',
    ).readAsStringSync();

    expect(worker, contains('FlutterEngine('));
    expect(worker, contains('null,\n                    false,'));
    expect(worker, isNot(contains('GeneratedPluginRegistrant')));
    expect(worker, isNot(contains('org.unifiedpush')));
    expect(worker, contains('PathProviderPlugin()'));
    expect(worker, contains('FlutterSecureStoragePlugin()'));
    expect(worker, contains('SqflitePlugin()'));
    expect(worker, contains('Sqlite3FlutterLibsPlugin()'));
  });

  test('unfinished jobs are restored when clients become available', () {
    final manager = File(
      'lib/src/widgets/matrix/client_manager/client_manager.dart',
    ).readAsStringSync();
    final queue = File(
      'lib/src/utils/matrix/media_upload_queue.dart',
    ).readAsStringSync();

    expect(manager, contains('MediaUploadQueue.reschedulePending()'));
    expect(queue, contains('prepareHeadlessPushClient(client)'));
    expect(queue, contains('MatrixStoreLease.acquire()'));
    expect(queue, contains('processing.lock'));
    expect(queue, contains('await _completeJob(directory)'));
  });
}
