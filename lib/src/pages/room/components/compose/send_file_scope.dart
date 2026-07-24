import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/file_selector.dart';
import '../../../../utils/matrix/media_upload_queue.dart';
import '../../../../widgets/intent_manager.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import 'compose_scope.dart';
import 'sticker_pack_bottom_sheet.dart';

class SendFileScopeWidget extends StatefulWidget {
  const SendFileScopeWidget({super.key, required this.child});

  final Widget child;

  @override
  State<SendFileScopeWidget> createState() => SendFileScope();
}

class _SendFileScope extends InheritedWidget {
  const _SendFileScope({
    required this.scope,
    required super.child,
  });

  final SendFileScope scope;

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class SendFileScope extends State<SendFileScopeWidget> {
  static SendFileScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_SendFileScope>()!.scope;

  int? _handledSharePayloadId;
  bool _shareDeliveryInProgress = false;

  @override
  void initState() {
    IntentManager.sharedPayloadListener.addListener(_scheduleSharedData);
    _scheduleSharedData();
    super.initState();
  }

  @override
  void dispose() {
    IntentManager.sharedPayloadListener.removeListener(_scheduleSharedData);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _SendFileScope(scope: this, child: widget.child);

  Future<void> showStickerSelector(String? msgType) async {
    final room = RoomScope.of(context).room;
    final emote = await StickerPackBottomSheet(
      room: room,
    ).showBottomSheet(context);
    if (emote == null || !mounted) {
      return;
    }
    ComposeScope.of(context).setSendMsgType();
    await room.sendEvent(
      {
        'body': MessageTypes.Sticker,
        'url': emote.url.toString(),
        'info': emote.info,
      },
      type: MessageTypes.Sticker,
      inReplyTo: ComposeScope.of(context).replyEvent,
      editEventId: ComposeScope.of(context).editEvent?.eventId,
    );
  }

  Future<void> sendKeyboardSticker(KeyboardInsertedContent sticker) async {
    final room = RoomScope.of(context).room;
    Uint8List? bytes = sticker.data;
    try {
      final compose = ComposeScope.of(context);
      if (bytes == null) {
        if (!kIsWeb && Platform.isAndroid) {
          await FileSelector.ensureAndroidInitialized();
          final tmp = await getTemporaryDirectory();
          final file = File(
            '${tmp.path}/import.${extensionFromMime(sticker.mimeType) ?? 'file'}',
          );
          await MediaStore().readFileUsingUri(
            uriString: sticker.uri,
            tempFilePath: file.path,
          );
          bytes = await file.readAsBytes();
        } else {
          return;
        }
      }

      final uri = await room.client.uploadContent(bytes);
      await room.sendEvent(
        {
          'body': MessageTypes.Sticker,
          'url': uri.toString(),
        },
        type: MessageTypes.Sticker,
        inReplyTo: compose.replyEvent,
        editEventId: compose.editEvent?.eventId,
      );
    } catch (e, s) {
      Logs().e('Error sending sticker', e, s);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorSendingSticker),
        ),
      );
    }
  }

  Future<void> sendFile(String? msgType) async {
    final selector = FileSelector(msgType);
    if (await selector.selectFiles(context) != true) {
      return;
    }
    if (!mounted) {
      return;
    }
    await sendFileSelection(selector);
    if (!mounted) {
      return;
    }
    ComposeScope.of(context).setSendMsgType();
  }

  Future<bool> sendFileSelection(FileSelector selector) async {
    final room = RoomScope.of(context).room;
    final selection = await selector.previewSelection(context);
    if (!mounted) {
      return false;
    }
    final files = selection?.files;
    if (selection == null || files == null || files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noFilesSelected),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).sendingFiles(files.length),
        ),
      ),
    );

    final matrixFiles = await selector.makeMatrixFiles(
      context,
      room.client.nativeImplementations,
    );
    for (final tuple in matrixFiles) {
      unawaited(_sendFileTransaction(tuple));
    }
    return true;
  }

  Future<void> sendVoiceMessage({
    required MatrixAudioFile file,
    required Duration duration,
    required List<int> waveform,
  }) =>
      _sendFileTransaction(
        MatrixFileTuple(file: file),
        extraContent: {
          'org.matrix.msc3245.voice': <String, dynamic>{},
          'org.matrix.msc1767.audio': {
            'duration': duration.inMilliseconds,
            'waveform': waveform,
          },
        },
      );

  void _scheduleSharedData() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendSharedData());
  }

  Future<void> _sendSharedData() async {
    if (!mounted || _shareDeliveryInProgress) {
      return;
    }
    final payload = IntentManager.sharedPayloadListener.value;
    if (payload == null || payload.roomId == null) {
      _handledSharePayloadId = null;
      return;
    }
    final room = RoomScope.of(context).room;
    if (payload.clientName != room.client.clientName ||
        payload.roomId != room.id ||
        _handledSharePayloadId == payload.id) {
      return;
    }

    _handledSharePayloadId = payload.id;
    final message = payload.text;
    if (message != null) {
      ComposeScope.of(context).messageController.text = message;
    }
    if (!payload.hasFiles) {
      return;
    }

    _shareDeliveryInProgress = true;
    try {
      final selector = FileSelector(null)..files = payload.files;
      final result = await sendFileSelection(selector);
      if (result) {
        await IntentManager.claimShareIntent();
      } else {
        IntentManager.clearShareDestination();
        if (mounted) {
          context.go('/share');
        }
      }
      if (!mounted) {
        return;
      }
      ComposeScope.of(context).setSendMsgType();
    } finally {
      _shareDeliveryInProgress = false;
    }
  }

  Future<void> _sendFileTransaction(
    MatrixFileTuple tuple, {
    Map<String, dynamic>? extraContent,
  }) async {
    final room = RoomScope.of(context).room;
    final compose = ComposeScope.of(context);
    final replyEvent = compose.replyEvent;
    final editEvent = compose.editEvent;
    final description = tuple.description?.trim();
    final effectiveExtraContent = <String, dynamic>{
      if (extraContent != null) ...extraContent,
      if (tuple.file is MatrixImageFile && description?.isNotEmpty == true)
        'body': description,
      if (tuple.file is MatrixImageFile && description?.isNotEmpty == true)
        'filename': tuple.file.name,
    };
    final txid = room.client.generateUniqueTransactionId();
    final job = await MediaUploadQueue.enqueue(
      client: room.client,
      roomId: room.id,
      txid: txid,
      file: tuple.file,
      thumbnail: tuple.thumbnail,
      replyEventId: replyEvent?.eventId,
      editEventId: editEvent?.eventId,
      extraContent:
          effectiveExtraContent.isEmpty ? null : effectiveExtraContent,
    );

    final operation = compose.txids[txid] = CancelableOperation.fromFuture(
      MediaUploadQueue.runForeground(
        job,
        () => room.sendFileEvent(
          tuple.file,
          thumbnail: tuple.thumbnail,
          inReplyTo: replyEvent,
          editEventId: editEvent?.eventId,
          txid: txid,
          extraContent:
              effectiveExtraContent.isEmpty ? null : effectiveExtraContent,
        ),
      ),
    );

    await operation.value;

    compose.txids.remove(txid);
  }
}
