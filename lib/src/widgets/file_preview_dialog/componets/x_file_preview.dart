import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';

import 'fallback_preview.dart';
import 'file_actions.dart';
import 'image_preview.dart';

class XFilePreview extends StatelessWidget {
  const XFilePreview({super.key, required this.file, required this.onRemove});

  static const _size = Size(192 + 32, 256);

  final XFile file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final mimePrefix = file.mimeType?.split('/').firstOrNull ??
        file.name.split('.').lastOrNull;
    return SizedBox.fromSize(
      size: _size,
      child: FileActions(
        file: file,
        onDelete: onRemove,
        child: switch (mimePrefix) {
          'image' ||
          'png' ||
          'apng' ||
          'jpg' ||
          'jpeg' ||
          'webp' ||
          'avif' ||
          'gif' ||
          'bmp' ||
          'wbmp' ||
          'svg' ||
          'tiff' ||
          'json' ||
          'zip' ||
          'lottie' ||
          'gzip' ||
          'tgs' =>
            ImagePreview(file: file),
          null || _ => FallbackPreview(file: file),
        },
      ),
    );
  }
}

bool isImageXFile(XFile file) {
  final type = file.mimeType?.split('/').firstOrNull ??
      file.name.split('.').lastOrNull?.toLowerCase();
  return const {
    'image',
    'png',
    'apng',
    'jpg',
    'jpeg',
    'webp',
    'avif',
    'gif',
    'bmp',
    'wbmp',
    'svg',
    'tiff',
    'json',
    'zip',
    'lottie',
    'gzip',
    'tgs',
  }.contains(type);
}
