import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:matrix/matrix.dart';

import '../device_pixel_ratio_builder.dart';
import '../mimed_image.dart';

typedef MxcUriImageBuilderCallback = Widget Function(
  BuildContext context,
  AsyncSnapshot<Widget> image,
  VoidCallback? retryCallback,
);

class MxcUriImageBuilder extends StatefulWidget {
  const MxcUriImageBuilder._({
    super.key,
    required this.uri,
    required this.client,
    this.imageBuilder = defaultImageBuilder,
    this.width,
    this.height,
    this.ratio = 1,
  });

  static Widget dpiRespective({
    Key? key,
    required Uri? uri,
    required Client client,
    MxcUriImageBuilderCallback imageBuilder = defaultImageBuilder,
    double? width,
    double? height,
  }) =>
      DevicePixelRatioBuilder(
        builder: (context, ratio) => MxcUriImageBuilder._(
          key: key,
          uri: uri,
          client: client,
          imageBuilder: imageBuilder,
          width: width,
          height: height,
          ratio: ratio,
        ),
      );

  static final Map<String, Uint8List> _runtimeCache = {};

  static Widget defaultImageBuilder(
    BuildContext context,
    AsyncSnapshot<Widget> image,
    VoidCallback? retryCallback,
  ) =>
      image.data ?? Container();

  final Uri? uri;
  final Client client;
  final MxcUriImageBuilderCallback imageBuilder;
  final double? width;
  final double? height;
  final double ratio;

  @override
  State<MxcUriImageBuilder> createState() => _MxcUriImageBuilderState();
}

class _MxcUriImageBuilderState extends State<MxcUriImageBuilder> {
  CancelableOperation<Widget>? imageOperation;
  AsyncSnapshot<Widget> image = const AsyncSnapshot.nothing();

  @override
  void initState() {
    startImageOperation();

    super.initState();
  }

  Future<Uri>? getDownloadUri() {
    final width = widget.width;
    final height = widget.height;
    return widget.uri?.getThumbnailUri(
      widget.client,
      width: width == null ? null : width * widget.ratio,
      height: height == null ? null : height * widget.ratio,
    );
  }

  @override
  Widget build(BuildContext context) {
    final retryCallback = image.hasError ? retry : null;
    return widget.imageBuilder.call(context, image, retryCallback);
  }

  @override
  void didUpdateWidget(covariant MxcUriImageBuilder oldWidget) {
    if (oldWidget.uri != widget.uri ||
        oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.ratio != widget.ratio) {
      unawaited(startImageOperation());
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    imageOperation?.cancel();
    super.dispose();
  }

  Future<Uint8List> _downloadCacheMxc(Uri mxcUri) async {
    final cached = MxcUriImageBuilder._runtimeCache[mxcUri.toString()];
    if (cached is Uint8List) {
      return cached;
    }

    final database = widget.client.database;
    final stored = await database?.getFile(mxcUri);
    if (stored is Uint8List) {
      return stored;
    }

    final httpClient = widget.client.httpClient;
    final response = await httpClient.get(
      mxcUri,
      headers: {'authorization': 'Bearer ${widget.client.accessToken}'},
    );
    if (response.statusCode != 200) {
      throw response;
    }

    final bytes = response.bodyBytes;
    if (bytes.length < (database?.maxFileSize ?? 5 * 1024 * 1024)) {
      MxcUriImageBuilder._runtimeCache[mxcUri.toString()] = bytes;
      if (database != null) {
        await database.storeFile(
          mxcUri,
          bytes,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    }
    return bytes;
  }

  Future<Widget> _buildCachedImageWidget(Uri uri) async {
    final bytes = await _downloadCacheMxc(uri);

    return MimedImage(
      key: ValueKey(widget.uri),
      bytes: bytes,
      path: uri.path,
      width: widget.width,
      height: widget.height,
    );
  }

  Future<void> startImageOperation() async {
    final uri = await getDownloadUri();
    if (uri == null) {
      return;
    }
    try {
      final operation = imageOperation = CancelableOperation.fromFuture(
        _buildCachedImageWidget(uri),
        onCancel: () {
          image = const AsyncSnapshot.withError(
            ConnectionState.none,
            TickerCanceled(),
          );
          try {
            if (mounted) {
              setState(() {});
            }
          } catch (_) {}
        },
      );
      image = const AsyncSnapshot.waiting();
      if (mounted) {
        setState(() {});
      }
      final file = await operation.value;

      image = AsyncSnapshot.withData(ConnectionState.done, file);
      if (mounted) {
        setState(() {});
      }
    } catch (e, s) {
      image = AsyncSnapshot.withError(ConnectionState.none, e, s);
      if (mounted) {
        setState(() {});
      }
    }
  }

  void retry() {
    if (image.hasError) {
      startImageOperation();
    }
  }
}
