import 'package:flutter/material.dart';

import '../ascii_progress_indicator.dart';
import '../blur_hash_widget.dart';
import '../polycule_text_shadow.dart';
import 'scopes/event_scope.dart';

class BlurHashIndicator extends StatelessWidget {
  const BlurHashIndicator({
    super.key,
    this.size = const Size(640, 360),
    this.label = const AsciiProgressIndicator(),
  });

  final Widget label;
  final Size size;

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    final info = event.infoMap as Map<String, Object?>?;
    final thumbnailInfo = event.thumbnailInfoMap as Map<String, Object?>?;
    final infoWidth = thumbnailInfo?['w'] as num? ?? info?['w'] as num?;
    final infoHeight = thumbnailInfo?['h'] as num? ?? info?['h'] as num?;

    final width = infoWidth ?? size.width;
    final height = infoHeight ?? size.height;

    final blurHash = info?['xyz.amorgan.blurhash'] as String?;

    return SizedBox(
      width: width.toDouble(),
      height: height.toDouble(),
      child: Stack(
        fit: StackFit.loose,
        alignment: Alignment.center,
        children: [
          if (blurHash is String)
            SizedBox(
              width: width.toDouble(),
              height: height.toDouble(),
              child: BlurHashWidget(
                blurHash: blurHash,
                width: width,
                height: height,
              ),
            ),
          PolyculeTextShadow(
            child: label,
          ),
        ],
      ),
    );
  }
}
