import 'package:flutter/material.dart';

import 'html/components/animated_emoji_extension.dart';

class ReactionChip extends StatelessWidget {
  const ReactionChip({super.key, required this.content});

  final String content;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Chip(
          labelPadding: const EdgeInsets.symmetric(
            horizontal: 4,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
          ),
          label: Text.rich(
            AnimatedEmojiExtension.emojifyTextSpan(content),
          ),
        ),
      ),
    );
  }
}
