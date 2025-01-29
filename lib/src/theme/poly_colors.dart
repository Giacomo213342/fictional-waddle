import 'dart:ui';

import 'package:csslib/parser.dart' as css;

class PolyColors {
  const PolyColors._();

  static const cyan = Color(0xff00c2ff);
  static const pink = Color(0xffff006a);
  static const grey = Color(0xff0a1027);
  static const white = Color(0xffffffff);

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
}
