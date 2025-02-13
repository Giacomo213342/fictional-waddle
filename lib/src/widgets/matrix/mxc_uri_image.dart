import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:async/async.dart';
import 'package:matrix/matrix.dart';

import '../device_pixel_ratio_builder.dart';
import '../mimed_image.dart';
import 'scopes/client_scope.dart';

typedef MxcUriImageBuilderCallback = Widget Function(
  BuildContext context,
  AsyncSnapshot<Widget> image,
  VoidCallback? retryCallback,
);

class MxcUriImageBuilder extends StatefulWidget {
  const MxcUriImageBuilder({
    super.key,
    required this.uri,
    this.imageBuilder = defaultImageBuilder,
    this.width,
    this.height,
    this.ratio = 1,
    this.fit,
  });

  static Widget dpiRespective({
    Key? key,
    required Uri? uri,
    MxcUriImageBuilderCallback imageBuilder = defaultImageBuilder,
    double? width,
    double? height,
    BoxFit? fit,
  }) =>
      DevicePixelRatioBuilder(
        builder: (context, ratio) => MxcUriImageBuilder(
          key: key,
          uri: uri,
          imageBuilder: imageBuilder,
          width: width,
          height: height,
          ratio: ratio,
          fit: fit,
        ),
      );

  static final Map<Uri, Map<int, Uint8List>> _runtimeCache = {};

  static Widget defaultImageBuilder(
    BuildContext context,
    AsyncSnapshot<Widget> image,
    VoidCallback? retryCallback,
  ) =>
      image.data ?? Container();

  final Uri? uri;
  final MxcUriImageBuilderCallback imageBuilder;
  final double? width;
  final double? height;
  final double ratio;
  final BoxFit? fit;

  @override
  State<MxcUriImageBuilder> createState() => _MxcUriImageBuilderState();
}

class _MxcUriImageBuilderState extends State<MxcUriImageBuilder> {
  CancelableOperation<Widget>? imageOperation;
  AsyncSnapshot<Widget> image = const AsyncSnapshot.nothing();

  Map<int, Uint8List>? get _cacheField {
    final uri = widget.uri;
    if (uri == null) {
      return null;
    }
    return MxcUriImageBuilder._runtimeCache[uri] ??= {};
  }

  int get _cacheKey =>
      widget.ratio.toInt() *
      (widget.width?.toInt() ?? 1) *
      (widget.height?.toInt() ?? 1);

  @override
  void initState() {
    final uri = widget.uri;
    if (uri == null) {
      return;
    }
    final cached = _cacheField?[_cacheKey];
    if (cached != null) {
      Logs().v(
        'Found MxcUri runtime cache for ${widget.uri}. Skipping Uri lookup.',
      );
      image = AsyncSnapshot.withData(
        ConnectionState.done,
        _buildWidget(cached, uri.path),
      );
    } else {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => startImageOperation());
    }

    super.initState();
  }

  Future<Uri>? getDownloadUri() {
    final client = ClientScope.of(context).client;
    final width = widget.width;
    final height = widget.height;
    if (width == null && height == null) {
      return widget.uri?.getDownloadUri(client);
    }
    return widget.uri?.getThumbnailUri(
      client,
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

  Future<Uint8List> _downloadMaybeCachedMxcUri(Uri mxcUri) async {
    final client = ClientScope.of(context).client;
    final cached = _cacheField?[_cacheKey];
    if (cached is Uint8List) {
      return cached;
    }

    final database = client.database;
    final stored = await database?.getFile(mxcUri);
    if (stored is Uint8List) {
      return stored;
    }

    final httpClient = client.httpClient;
    final response = await httpClient.get(
      mxcUri,
      headers: {'authorization': 'Bearer ${client.accessToken}'},
    );
    if (response.statusCode != 200) {
      throw response;
    }

    final bytes = response.bodyBytes;
    if (bytes.length < (database?.maxFileSize ?? 5 * 1024 * 1024)) {
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
    final bytes = await _downloadMaybeCachedMxcUri(uri);
    _cacheField?[_cacheKey] = bytes;
    return _buildWidget(bytes, uri.path);
  }

  Widget _buildWidget(Uint8List bytes, String name) => MimedImage(
        key: ValueKey(widget.uri),
        bytes: bytes,
        name: name,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
      );

  Future<void> startImageOperation() async {
    if (!mounted) {
      return;
    }
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
