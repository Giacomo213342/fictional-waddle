import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:dart_animated_emoji/dart_animated_emoji.dart';
import 'package:lottie/lottie.dart';

import 'matrix/animations_enabled_builder.dart';

class AnimatedEmojiLottieView extends StatelessWidget {
  const AnimatedEmojiLottieView({
    super.key,
    required this.emoji,
    required this.size,
    this.textColor,
  });

  final AnimatedEmoji emoji;
  final double? size;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final size = this.size ??
        ((DefaultTextStyle.of(context).style.fontSize ?? 18) * 1.25);
    return Semantics(
      label: emoji.name,
      child: SizedBox.square(
        dimension: size,
        child: Semantics(
          excludeSemantics: true,
          child: AnimationEnabledBuilder(
            iconSize: size / 2.5,
            builder: (context, animate) {
              return Lottie.memory(
                key: ValueKey(emoji.name + size.toString()),
                Uint8List.fromList(emoji.lottieAnimation.codeUnits),
                animate: animate,
              );
            },
          ),
        ),
      ),
    );
  }
}
