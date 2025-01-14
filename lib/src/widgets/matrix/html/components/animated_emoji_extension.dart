import 'package:flutter/material.dart' hide Element, Text;

import 'package:dart_animated_emoji/dart_animated_emoji.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart';

import '../../../../utils/parent_font_size_extension.dart';
import '../../../animated_emoji_lottie_view.dart';

class AnimatedEmojiExtension extends HtmlExtension {
  const AnimatedEmojiExtension();

  static const kEmojiAttribute = 'data-polycule-animated-emoji';

  static final animatedEmojiCodePoints =
      AnimatedEmoji.all.map((e) => e.fallback).toList(growable: false);

  static List<T> _emojifyText<T>(
    String text, {
    required T Function(String text) textBuilder,
    required T Function(String emoji) emojiBuilder,
  }) {
    final emojis = text.emojis;

    if (!emojis.contains) {
      return [textBuilder.call(text)];
    }
    final first = emojis.first;

    int lastIndex = text.indexOf(first.value);
    final initialValue = <T>[
      if (lastIndex != 0)
        textBuilder.call(
          text.substring(0, lastIndex),
        ),
    ];
    return emojis.foldIndexed<List<T>>(initialValue, (index, nodes, emoji) {
      final unicode = emoji.value;
      if (animatedEmojiCodePoints.contains(unicode)) {
        nodes.add(emojiBuilder.call(unicode));
      } else {
        nodes.add(textBuilder.call(unicode));
      }
      lastIndex = text.indexOf(unicode, lastIndex) + unicode.length;

      if (lastIndex < text.length) {
        if (index + 1 < emojis.count) {
          nodes.add(
            textBuilder.call(
              text.substring(
                lastIndex,
                text.indexOf(
                  emojis.get[index + 1].value,
                  lastIndex,
                ),
              ),
            ),
          );
        } else {
          nodes.add(
            textBuilder.call(
              text.substring(lastIndex),
            ),
          );
        }
      }
      return nodes;
    });
  }

  static List<Node> emojifyTextNode(String text) {
    return _emojifyText(
      text,
      textBuilder: (text) => Text(text),
      emojiBuilder: (emoji) => Element.tag('span')
        ..attributes[kEmojiAttribute] = emoji
        ..text = emoji,
    );
  }

  static InlineSpan emojifyTextSpan(String text) {
    return TextSpan(
      children: _emojifyText(
        text,
        textBuilder: (text) => TextSpan(text: text),
        emojiBuilder: _lottieSpan,
      ),
    );
  }

  static WidgetSpan _lottieSpan(String emoji, [double? size]) {
    return WidgetSpan(
      child: AnimatedEmojiLottieView(
        emoji: AnimatedEmoji.all.singleWhere(
          (e) => e.fallback == emoji,
        ),
        size: size,
      ),
    );
  }

  @override
  Set<String> get supportedTags => {'span'};

  @override
  bool matches(ExtensionContext context) {
    if (!supportedTags.contains(context.elementName)) {
      return false;
    }

    return (context.attributes.containsKey(kEmojiAttribute));
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final emojiText = context.element?.innerHtml;
    try {
      final fontSize = context.tryGetParentFontSize()?.emValue ?? 12;
      final size = fontSize * 1.25;

      return _lottieSpan(
        emojiText!,
        size,
      );
    } catch (_) {
      return TextSpan(text: emojiText);
    }
  }
}
