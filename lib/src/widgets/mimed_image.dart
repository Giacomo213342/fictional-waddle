import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:mime/mime.dart';

class MimedImage extends StatelessWidget {
  const MimedImage({
    super.key,
    required this.bytes,
    required this.path,
    this.width,
    this.height,
    this.fit,
  });

  final Uint8List bytes;
  final String path;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final mime = lookupMimeType(
      path,
      headerBytes: bytes.getRange(0, min(64, bytes.length)).toList(),
    );

    if (mime == null) {
      return _bitmapImage(bytes);
    }

    if (mime.contains('svg') || mime.contains('xml')) {
      return _svgImage(bytes);
    }
    if (mime == 'application/json') {
      // TODO: support Lottie
    }

    return _bitmapImage(bytes);
  }

  Image _bitmapImage(Uint8List bytes) {
    return Image.memory(
      bytes,
      gaplessPlayback: true,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
    );
  }

  SvgPicture _svgImage(Uint8List bytes) {
    return SvgPicture.memory(
      bytes,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
    );
  }
}
