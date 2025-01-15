import 'package:flutter/material.dart' hide Element, Text;

import 'package:flutter_html/flutter_html.dart';

import '../../../../theme/fonts.dart';
import 'animated_emoji_extension.dart';

class PolyculeEmojiSpanExtension extends HtmlExtension {
  const PolyculeEmojiSpanExtension();

  @override
  Set<String> get supportedTags => {'span'};

  @override
  bool matches(ExtensionContext context) =>
      supportedTags.contains(context.elementName) &&
      context.classes.contains(AnimatedEmojiExtension.kEmojiClass);

  @override
  InlineSpan build(ExtensionContext context) => TextSpan(
        text: context.element?.innerHtml,
        style: TextStyle(
          fontFamily: PolyculeFonts.notoColorEmoji.name,
        ),
      );
}
