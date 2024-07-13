import 'dart:async';

import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:matrix/matrix.dart';

typedef ThumbnailAttachmentBuilder<T, U> = Widget Function(
  BuildContext context,
  AsyncSnapshot<U?> thumbnail,
  AsyncSnapshot<T?> attachment,
  VoidCallback? retryCallback,
);

enum ThumbnailRequest {
  thumbnailOnly,
  attachmentOnly,
  both,
}

typedef MatrixFileTransformer<T> = FutureOr<T?> Function(MatrixFile? file);

class MxcEncryptedFileBuilder<T, U> extends StatefulWidget {
  const MxcEncryptedFileBuilder({
    super.key,
    required this.event,
    required this.builder,
    this.thumbnail = ThumbnailRequest.both,
    this.attachmentTransformer,
    this.thumbnailTransformer,
  });

  static final Map<String, MatrixFile> _runtimeCache = {};

  final ThumbnailRequest thumbnail;
  final Event event;
  final ThumbnailAttachmentBuilder<T, U> builder;
  final MatrixFileTransformer<T>? attachmentTransformer;
  final MatrixFileTransformer<U>? thumbnailTransformer;

  bool get _getThumbnail =>
      thumbnail == ThumbnailRequest.both ||
      thumbnail == ThumbnailRequest.thumbnailOnly;

  bool get _getAttachment =>
      thumbnail == ThumbnailRequest.both ||
      thumbnail == ThumbnailRequest.attachmentOnly;

  @override
  State<MxcEncryptedFileBuilder> createState() =>
      _MxcEncryptedFileBuilderState<T, U>();
}

class _MxcEncryptedFileBuilderState<T, U>
    extends State<MxcEncryptedFileBuilder<T, U>> {
  CancelableOperation<U?>? thumbnailOperation;
  CancelableOperation<T?>? attachmentOperation;

  AsyncSnapshot<U?> thumbnail = const AsyncSnapshot.nothing();
  AsyncSnapshot<T?> attachment = const AsyncSnapshot.nothing();

  @override
  void initState() {
    if (widget._getThumbnail) {
      startThumbnailOperation();
    }
    if (widget._getAttachment) {
      startAttachmentOperation();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final retryCallback =
        attachment.hasError || thumbnail.hasError ? retry : null;
    return widget.builder.call(context, thumbnail, attachment, retryCallback);
  }

  @override
  void dispose() {
    thumbnailOperation?.cancel();
    attachmentOperation?.cancel();
    super.dispose();
  }

  Future<MatrixFile> downloadAttachment() async {
    final cached = MxcEncryptedFileBuilder
        ._runtimeCache[widget.event.attachmentMxcUrl.toString()];

    if (cached is MatrixFile) {
      return cached;
    }

    final file = await widget.event.downloadAndDecryptAttachment(
      getThumbnail: false,
    );

    MxcEncryptedFileBuilder
        ._runtimeCache[widget.event.attachmentMxcUrl.toString()] = file;

    return file;
  }

  Future<MatrixFile?> downloadThumbnail() async {
    final thumbnailUrl = widget.event.thumbnailMxcUrl;
    if (thumbnailUrl == null) {
      return null;
    }

    final cached =
        MxcEncryptedFileBuilder._runtimeCache[thumbnailUrl.toString()];

    if (cached is MatrixFile) {
      return cached;
    }

    final file = await widget.event.downloadAndDecryptAttachment(
      getThumbnail: true,
    );

    MxcEncryptedFileBuilder._runtimeCache[thumbnailUrl.toString()] = file;

    return file;
  }

  Future<void> startThumbnailOperation() async {
    try {
      final operation = thumbnailOperation = CancelableOperation.fromFuture(
        downloadThumbnail()
            .then(widget.thumbnailTransformer ?? (file) => file as U?),
        onCancel: () {
          thumbnail = const AsyncSnapshot.withData(ConnectionState.none, null);
          if (mounted) {
            setState(() {});
          }
        },
      );
      thumbnail = const AsyncSnapshot.waiting();
      if (mounted) {
        setState(() {});
      }
      final file = await operation.value;
      if (file == null && widget.thumbnail == ThumbnailRequest.thumbnailOnly) {
        startAttachmentOperation();
      }

      thumbnail = AsyncSnapshot.withData(ConnectionState.done, file);
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      thumbnail = AsyncSnapshot.withError(ConnectionState.none, e);
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> startAttachmentOperation() async {
    try {
      final operation = attachmentOperation = CancelableOperation.fromFuture(
        downloadAttachment()
            .then(widget.attachmentTransformer ?? (file) => file as T?),
        onCancel: () {
          attachment = const AsyncSnapshot.withData(ConnectionState.none, null);
          if (mounted) {
            setState(() {});
          }
        },
      );
      attachment = const AsyncSnapshot.waiting();
      if (mounted) {
        setState(() {});
      }
      final file = await operation.value;

      attachment = AsyncSnapshot.withData(ConnectionState.done, file);
      if (mounted) {
        setState(() {});
      }
      await thumbnailOperation?.cancel();
    } catch (e) {
      attachment = AsyncSnapshot.withError(ConnectionState.none, e);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void retry() {
    if (thumbnail.hasError) {
      startThumbnailOperation();
    }
    if (attachment.hasError) {
      startAttachmentOperation();
    }
  }
}
