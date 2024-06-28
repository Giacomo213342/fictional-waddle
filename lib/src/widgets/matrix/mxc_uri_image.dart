import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class MxcUriImage extends StatelessWidget {
  const MxcUriImage({
    super.key,
    required this.uri,
    required this.client,
    this.width,
    this.height,
  });

  static final Map<String, Uint8List> _runtimeCache = {};

  final Uri uri;
  final Client client;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final downloadUri = uri.getThumbnail(
      client,
      width: width,
      height: height,
    );
    return FutureBuilder<Uint8List?>(
      initialData: _runtimeCache[downloadUri.toString()],
      future: downloadCacheMxc(downloadUri),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) {
          return Container();
        }
        return Image.memory(
          key: ValueKey(downloadUri),
          bytes,
          gaplessPlayback: true,
          fit: BoxFit.cover,
          width: width,
          height: height,
        );
      },
    );
  }

  Future<Uint8List?> downloadCacheMxc(Uri mxcUri) async {
    final cached = _runtimeCache[mxcUri.toString()];
    if (cached is Uint8List) {
      return cached;
    }

    final database = client.database;
    final stored = await database?.getFile(mxcUri);
    if (stored is Uint8List) {
      return stored;
    }

    final httpClient = client.httpClient;
    final response = await httpClient.get(mxcUri);
    if (response.statusCode != 200) {
      return null;
    }

    final bytes = response.bodyBytes;
    if (bytes.length < (database?.maxFileSize ?? 5 * 1024 * 1024)) {
      _runtimeCache[mxcUri.toString()] = bytes;
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
}
