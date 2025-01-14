import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';

import '../../mimed_image.dart';
import 'fallback_preview.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({super.key, required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return FallbackPreview(file: file);
          }

          return MimedImage(
            bytes: data,
            name: file.name,
            mimeType: file.mimeType,
            fit: BoxFit.contain,
          );
        },
      );
}
