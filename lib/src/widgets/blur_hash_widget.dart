import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:image/image.dart' show encodePng;

class BlurHashWidget extends StatelessWidget {
  const BlurHashWidget({
    super.key,
    required this.blurHash,
    required this.width,
    required this.height,
  });

  final String blurHash;
  final num width;
  final num height;

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      Uint8List.fromList(
        encodePng(
          BlurHash.decode(blurHash).toImage(
            // speed up rendering
            (width / 5).round(),
            (height / 5).round(),
          ),
        ),
      ),
      width: width.toDouble(),
      height: height.toDouble(),
      fit: BoxFit.contain,
    );
  }
}
