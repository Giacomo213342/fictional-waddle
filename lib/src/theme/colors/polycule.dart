import 'package:flutter/animation.dart';

import 'package:csslib/parser.dart' as css;

abstract class PolyculeColors {
  const PolyculeColors._();

  static Color parseCss(String color) {
    final colorEntry = css.TokenKind.matchColorName(color);
    if (colorEntry != null) {
      final value = colorEntry['value'];
      if (value is int) {
        final argb = 0xFF000000 + value;
        return Color(argb);
      }
    }
    final cssColor = css.Color.css(color).rgba;
    return Color.fromARGB(
      cssColor.a?.toInt() ?? 255,
      cssColor.r,
      cssColor.g,
      cssColor.b,
    );
  }

  static TweenSequence<Color?> tween(List<Color> colors) {
    final sequences = <TweenSequenceItem<Color?>>[];
    for (int i = 0; i < colors.length; i++) {
      sequences.add(
        TweenSequenceItem(
          tween: ColorTween(
            begin: colors[i],
            end: colors[i + 1 >= colors.length ? 0 : i + 1],
          ),
          weight: 1,
        ),
      );
    }
    return TweenSequence(sequences);
  }
}
