import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class MxcImage extends StatelessWidget {
  const MxcImage({
    super.key,
    required this.uri,
    required this.client,
    this.width,
    this.height,
  });

  final Uri uri;
  final Client client;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      uri
          .getThumbnail(
            client,
            width: width,
            height: height,
          )
          .toString(),
      fit: BoxFit.cover,
      width: width,
      height: height,
    );
  }
}
