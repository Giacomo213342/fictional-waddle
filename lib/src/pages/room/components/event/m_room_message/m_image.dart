import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../widgets/matrix/blur_hash_spinner.dart';

class ImageMessage extends StatelessWidget {
  const ImageMessage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 512, maxWidth: 512),
      child: FutureBuilder(
        key: ValueKey(event.attachmentMxcUrl),
        future: event.downloadAndDecryptAttachment(
          getThumbnail: true,
        ),
        builder: (context, snapshot) {
          final data = snapshot.data;
          if (data == null) {
            return BlurHashSpinner(event: event);
          }
          return Image.memory(data.bytes);
        },
      ),
    );
  }
}
