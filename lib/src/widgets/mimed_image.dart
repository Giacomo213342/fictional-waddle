import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui show Image;
import 'dart:ui' hide Image;

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

  // analyzes the frames of a bitmap and either just returns the image or its
  // first frame in case its animated and the user requests to avoid animations
  Widget _bitmapImage(Uint8List bytes) => FutureBuilder<ImageFutureResponse>(
        future: _analyzeImageFrames(bytes),
        builder: (context, snapshot) {
          final frames = snapshot.data;
          return switch (frames) {
            AnimatedThumbnailImageProviderFutureResponse() =>
              AnimationEnabledBuilder(
                builder: (context, animate) {
                  if (animate) {
                    return _buildBitmap(frames.imageProvider);
                  } else {
                    return _buildRawBitmap(frames.thumbnail);
                  }
                },
                iconSize: (height ?? 96) / 2.5,
              ),
            ImageProviderFutureResponse() => _buildBitmap(frames.imageProvider),
            _ => _buildRawBitmap(null),
          };
        },
      );

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

  Future<ImageFutureResponse> _analyzeImageFrames(Uint8List bytes) async {
    final provider = MemoryImage(bytes);

    final codec = await instantiateImageCodecWithSize(
      await ImmutableBuffer.fromUint8List(bytes),
    );
    if (codec.frameCount > 1) {
      final frame = await codec.getNextFrame();
      return AnimatedThumbnailImageProviderFutureResponse(
        thumbnail: frame.image,
        imageProvider: provider,
      );
    } else {
      return ImageProviderFutureResponse(provider);
    }
  }

  RawImage _buildRawBitmap(ui.Image? image) {
    return RawImage(
      image: image,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
      isAntiAlias: true,
    );
  }

  Image _buildBitmap<T extends Object>(ImageProvider<T> provider) {
    return Image(
      image: provider,
      gaplessPlayback: true,
      fit: fit ?? BoxFit.cover,
      width: width,
      height: height,
      isAntiAlias: true,
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

abstract class ImageFutureResponse {
  const ImageFutureResponse();
}

class ImageProviderFutureResponse extends ImageFutureResponse {
  const ImageProviderFutureResponse(this.imageProvider);

  final ImageProvider imageProvider;
}

class AnimatedThumbnailImageProviderFutureResponse
    extends ImageProviderFutureResponse {
  const AnimatedThumbnailImageProviderFutureResponse({
    required this.thumbnail,
    required ImageProvider imageProvider,
  }) : super(imageProvider);

  final ui.Image thumbnail;
}
