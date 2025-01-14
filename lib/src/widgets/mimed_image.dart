import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mime/mime.dart';

import 'matrix/animations_enabled_builder.dart';

class MimedImage extends StatelessWidget {
  const MimedImage({
    super.key,
    required this.bytes,
    required this.name,
    this.mimeType,
    this.width,
    this.height,
    this.fit,
  });

  final Uint8List bytes;
  final String name;
  final String? mimeType;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final mime = mimeType ??
        lookupMimeType(
          name,
          headerBytes: bytes.getRange(0, min(128, bytes.length)).toList(),
        );

    if (mime == 'application/json' ||
        mime == 'application/zip' ||
        mime == 'application/gzip' ||
        name.endsWith('.lottie') ||
        name.endsWith('.tgs')) {
      return _lottieImage(bytes, mime);
    }

    if (mime == null) {
      return _bitmapImage(bytes);
    }

    if (mime.contains('svg') || mime.contains('xml')) {
      return _svgImage(bytes);
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

  Widget _lottieImage(Uint8List bytes, [String? mimeType]) {
    return AnimationEnabledBuilder(
      builder: (context, animate) {
        return Lottie.memory(
          bytes,
          fit: fit ?? BoxFit.cover,
          width: width,
          height: height,
          decoder: mimeType == 'application/json' ? null : _lottieDecoder,
          animate: animate,
        );
      },
      iconSize: (height ?? 96) / 2.5,
    );
  }

  Future<LottieComposition?> _lottieDecoder(List<int> bytes) async =>
      // Telegram decoder
      await LottieComposition.decodeGZip(
        bytes,
      ) ??
      // dotLottie decoder
      await LottieComposition.decodeZip(
        bytes,
        // the default implementation does not look in the animations
        // subfolder and therefore sometimes selects the manifest.json
        // TODO: actually read the manifest
        filePicker: (files) => files.firstWhereOrNull(
          (file) =>
              file.name.startsWith('animations/') &&
              file.name.endsWith('.json'),
        ),
      );
}
