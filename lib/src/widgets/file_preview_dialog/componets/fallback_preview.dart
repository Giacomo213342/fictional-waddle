import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';

class FallbackPreview extends StatelessWidget {
  const FallbackPreview({super.key, required this.file});

  final XFile file;

  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.file_present);
  }
}
