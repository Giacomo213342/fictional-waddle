import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';

import '../runtime_suffix.dart';
import '../settings_interface.dart';
import '../polycule_http_client/polycule_http_client.dart';
import 'client_util.dart';
import 'database/matrix_store_lease.dart';
import 'push_handler.dart';

class MediaUploadJob {
  const MediaUploadJob({
    required this.id,
    required this.txid,
    required this.clientName,
    required this.roomId,
    required this.directory,
    required this.file,
    this.thumbnail,
    this.replyEventId,
    this.editEventId,
    this.extraContent,
  });

  final String id;
  final String txid;
  final String clientName;
  final String roomId;
  final Directory directory;
  final MatrixFile file;
  final MatrixImageFile? thumbnail;
  final String? replyEventId;
  final String? editEventId;
  final Map<String, dynamic>? extraContent;
}

class MediaUploadQueue {
  const MediaUploadQueue._();

  static const _scheduler = MethodChannel('polycule.media_uploads');
  static const _completion = MethodChannel('polycule.media_upload_worker');
  static const _manifestName = 'manifest.json';

  static Future<MediaUploadJob> enqueue({
    required Client client,
    required String roomId,
    required String txid,
    required MatrixFile file,
    MatrixImageFile? thumbnail,
    String? replyEventId,
    String? editEventId,
    Map<String, dynamic>? extraContent,
  }) async {
    final root = await _queueRoot();
    final directory = Directory('${root.path}/$txid');
    await directory.create(recursive: true);
    final payload = File('${directory.path}/payload.bin');
    await payload.writeAsBytes(file.bytes, flush: true);
    if (thumbnail != null) {
      await File(
        '${directory.path}/thumbnail.bin',
      ).writeAsBytes(thumbnail.bytes, flush: true);
    }
    final manifest = {
      'version': 1,
      'id': txid,
      'txid': txid,
      'clientName': client.clientName,
      'roomId': roomId,
      'createdAt': DateTime.now().toUtc().toIso8601String(),
      'file': _fileMetadata(file, 'payload.bin'),
      if (thumbnail != null)
        'thumbnail': _fileMetadata(thumbnail, 'thumbnail.bin'),
      if (replyEventId != null) 'replyEventId': replyEventId,
      if (editEventId != null) 'editEventId': editEventId,
      if (extraContent != null) 'extraContent': extraContent,
    };
    final temporary = File('${directory.path}/$_manifestName.tmp');
    await temporary.writeAsString(jsonEncode(manifest), flush: true);
    await temporary.rename('${directory.path}/$_manifestName');
    final job = MediaUploadJob(
      id: txid,
      txid: txid,
      clientName: client.clientName,
      roomId: roomId,
      directory: directory,
      file: file,
      thumbnail: thumbnail,
      replyEventId: replyEventId,
      editEventId: editEventId,
      extraContent: extraContent,
    );
    await _schedule(txid);
    return job;
  }

  static Future<T> runForeground<T>(
    MediaUploadJob job,
    Future<T> Function() upload,
  ) =>
      _withJobLock(job.directory, () async {
        final result = await upload();
        await _completeJob(job.directory);
        return result;
      });

  static Future<void> cancel(String jobId) async {
    try {
      await _scheduler.invokeMethod<void>('cancel', {'jobId': jobId});
    } on MissingPluginException {
      // Background scheduling is Android-only.
    }
    final directory = Directory('${(await _queueRoot()).path}/$jobId');
    await _completeJob(directory);
  }

  static Future<void> reschedulePending() async {
    final root = await _queueRoot();
    if (!await root.exists()) {
      return;
    }
    await for (final entity in root.list()) {
      if (entity is Directory &&
          await File('${entity.path}/$_manifestName').exists()) {
        await _schedule(entity.uri.pathSegments.last);
      }
    }
  }

  static Future<bool> process(String jobId) async {
    final directory = Directory('${(await _queueRoot()).path}/$jobId');
    return _withJobLock(directory, () async {
      final manifestFile = File('${directory.path}/$_manifestName');
      if (!await manifestFile.exists()) {
        return true;
      }
      Client? client;
      MatrixStoreLease? lease;
      try {
        final manifest = Map<String, dynamic>.from(
          jsonDecode(await manifestFile.readAsString()),
        );
        final clientName = manifest['clientName'];
        final roomId = manifest['roomId'];
        final txid = manifest['txid'];
        if (clientName is! String || roomId is! String || txid is! String) {
          return false;
        }

        final network = await const SettingsInterface().getNetwork(
          failClosed: true,
        );
        await PolyculeHttpClientManager.init(ValueNotifier(network));
        final callback = await PolyculeHttpClientManager.httpClientCallback;
        lease = await MatrixStoreLease.acquire();
        client = await ClientUtil.clientConstructor(
          clientName,
          callback.call(),
          requestTimeout: const Duration(seconds: 45),
        );
        await prepareHeadlessPushClient(client);
        final room = client.getRoomById(roomId);
        if (room == null) {
          return false;
        }

        final file = await _readMatrixFile(
          directory,
          Map<String, dynamic>.from(manifest['file'] as Map),
        );
        final thumbnailData = manifest['thumbnail'];
        final thumbnail = thumbnailData is Map
            ? await _readMatrixImageFile(
                directory,
                Map<String, dynamic>.from(thumbnailData),
              )
            : null;
        final replyEventId = manifest['replyEventId'];
        final storedExtraContent = manifest['extraContent'];
        final extraContent = <String, dynamic>{
          if (storedExtraContent is Map)
            ...Map<String, dynamic>.from(storedExtraContent),
          if (replyEventId is String)
            'm.relates_to': {
              'm.in_reply_to': {'event_id': replyEventId},
            },
        };
        await room.sendFileEvent(
          file,
          thumbnail: thumbnail,
          txid: txid,
          editEventId: manifest['editEventId'] as String?,
          extraContent: extraContent.isEmpty ? null : extraContent,
        );
        await _completeJob(directory);
        return true;
      } catch (error, stackTrace) {
        Logs().w(
          'Persistent media upload $jobId failed and will retry.',
          error,
          stackTrace,
        );
        return false;
      } finally {
        await client?.dispose();
        await lease?.release();
      }
    });
  }

  static Future<void> runWorker(String jobId) async {
    var success = false;
    try {
      success = await process(jobId);
    } finally {
      try {
        await _completion.invokeMethod<void>(
          'complete',
          {'success': success},
        );
      } on MissingPluginException {
        // Allows direct unit execution without an Android Worker.
      }
    }
  }

  static Future<void> _schedule(String jobId) async {
    if (kIsWeb || !Platform.isAndroid) {
      return;
    }
    try {
      await _scheduler.invokeMethod<void>('enqueue', {'jobId': jobId});
    } on MissingPluginException {
      // Foreground sending remains available on unsupported embeddings.
    }
  }

  static Future<Directory> _queueRoot() async {
    final support = await getApplicationSupportDirectory();
    final root = Directory(
      '${support.path}${getRuntimeSuffix()}/media-upload-queue',
    );
    await root.create(recursive: true);
    return root;
  }

  static Map<String, Object?> _fileMetadata(MatrixFile file, String path) => {
        'path': path,
        'name': file.name,
        'mimeType': file.mimeType,
        'msgType': file.msgType,
        'info': file.info,
      };

  static Future<MatrixFile> _readMatrixFile(
    Directory directory,
    Map<String, dynamic> metadata,
  ) async {
    final bytes = await _readBytes(directory, metadata);
    final info =
        Map<String, dynamic>.from(metadata['info'] as Map? ?? const {});
    final name = metadata['name'] as String;
    final mimeType = metadata['mimeType'] as String?;
    return switch (metadata['msgType']) {
      MessageTypes.Image => MatrixImageFile(
          bytes: bytes,
          name: name,
          mimeType: mimeType,
          width: info['w'] as int?,
          height: info['h'] as int?,
          blurhash: info['xyz.amorgan.blurhash'] as String?,
        ),
      MessageTypes.Video => MatrixVideoFile(
          bytes: bytes,
          name: name,
          mimeType: mimeType,
          width: info['w'] as int?,
          height: info['h'] as int?,
          duration: info['duration'] as int?,
        ),
      MessageTypes.Audio => MatrixAudioFile(
          bytes: bytes,
          name: name,
          mimeType: mimeType,
          duration: info['duration'] as int?,
        ),
      _ => MatrixFile(bytes: bytes, name: name, mimeType: mimeType),
    };
  }

  static Future<MatrixImageFile> _readMatrixImageFile(
    Directory directory,
    Map<String, dynamic> metadata,
  ) async {
    final file = await _readMatrixFile(directory, metadata);
    if (file is MatrixImageFile) {
      return file;
    }
    return MatrixImageFile(
      bytes: file.bytes,
      name: file.name,
      mimeType: file.mimeType,
    );
  }

  static Future<Uint8List> _readBytes(
    Directory directory,
    Map<String, dynamic> metadata,
  ) async {
    final relativePath = metadata['path'];
    if (relativePath is! String ||
        relativePath.contains('/') ||
        relativePath.contains(r'\')) {
      throw const FormatException('Invalid media upload payload path.');
    }
    return File('${directory.path}/$relativePath').readAsBytes();
  }

  static Future<T> _withJobLock<T>(
    Directory directory,
    Future<T> Function() operation,
  ) async {
    await directory.create(recursive: true);
    final lock = await File('${directory.path}/processing.lock').open(
      mode: FileMode.append,
    );
    await lock.lock(FileLock.exclusive);
    try {
      return await operation();
    } finally {
      await lock.unlock();
      await lock.close();
    }
  }

  static Future<void> _completeJob(Directory directory) async {
    if (!await directory.exists()) {
      return;
    }
    await for (final entity in directory.list()) {
      if (entity is File && !entity.path.endsWith('/processing.lock')) {
        await entity.delete();
      }
    }
  }
}
