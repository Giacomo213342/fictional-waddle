import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../widgets/blur_hash_widget.dart';
import '../../../../widgets/matrix/mxc_uri_image.dart';

class StickerPreview extends StatelessWidget {
  const StickerPreview({
    super.key,
    required this.name,
    required this.content,
    required this.client,
  });

  final String name;
  final ImagePackImageContent content;
  final Client client;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pop(content),
      child: Stack(
        fit: StackFit.expand,
        children: [
          MxcUriImageBuilder(
            uri: content.url,
            client: client,
            width: 256,
            height: 256,
            imageBuilder: (
              BuildContext context,
              AsyncSnapshot<Widget> image,
              VoidCallback? retryCallback,
            ) {
              final data = image.data;
              if (data != null) {
                return data;
              }

              final info = content.info;

              final blurHash = info?['xyz.amorgan.blurhash'] as String?;
              if (blurHash != null) {
                return BlurHashWidget(
                  blurHash: blurHash,
                  width: 256,
                  height: 256,
                );
              }
              return Container();
            },
          ),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              tooltip: ':$name:',
              onPressed: () {},
              icon: const Icon(Icons.info),
            ),
          ),
        ],
      ),
    );
  }
}
