import 'package:flutter/material.dart' hide Element, Text;

import 'package:dart_animated_emoji/dart_animated_emoji.dart';
import 'package:emoji_extension/emoji_extension.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart';

import '../../../../theme/fonts.dart';
import '../../../../utils/parent_font_size_extension.dart';
import '../../../animated_emoji_lottie_view.dart';

class AnimatedEmojiExtension extends HtmlExtension {
  const AnimatedEmojiExtension();

  static const kEmojiAttribute = 'data-polycule-animated-emoji';
  static const kEmojiClass = 'polycule-emoji';

  static final animatedEmojiCodePoints =
      AnimatedEmoji.all.map((e) => e.fallback).toList(growable: false);

  static List<T> _emojifyText<T>(
    String text, {
    required T Function(String text) defaultTextBuilder,
    required T Function(String emoji) emojiTextBuilder,
    required T Function(String emoji) animatedEmojiBuilder,
  }) {
    final emojis = text.emojis;

    if (!emojis.contains) {
      return [defaultTextBuilder.call(text)];
    }
    final first = emojis.first;

    int lastIndex = text.indexOf(first.value);
    final initialValue = <T>[
      if (lastIndex != 0)
        defaultTextBuilder.call(
          text.substring(0, lastIndex),
        ),
    ];
    return emojis.foldIndexed<List<T>>(initialValue, (index, nodes, emoji) {
      final unicode = emoji.value;
      if (animatedEmojiCodePoints.contains(unicode)) {
        nodes.add(animatedEmojiBuilder.call(unicode));
      } else {
        nodes.add(emojiTextBuilder.call(unicode));
      }
      lastIndex = text.indexOf(unicode, lastIndex) + unicode.length;

      if (lastIndex < text.length) {
        if (index + 1 < emojis.count) {
          nodes.add(
            defaultTextBuilder.call(
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
            defaultTextBuilder.call(
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
      defaultTextBuilder: (text) => Text(text),
      emojiTextBuilder: (emoji) => Element.tag('span')
        ..className = kEmojiClass
        ..text = emoji,
      animatedEmojiBuilder: (emoji) => Element.tag('span')
        ..attributes[kEmojiAttribute] = emoji
        ..text = emoji,
    );
  }

  static InlineSpan emojifyTextSpan(String text) {
    return TextSpan(
      children: _emojifyText(
        text,
        defaultTextBuilder: (text) => TextSpan(text: text),
        emojiTextBuilder: (emoji) => TextSpan(
          text: emoji,
          style: TextStyle(fontFamily: PolyculeFonts.notoColorEmoji.name),
        ),
        animatedEmojiBuilder: _lottieSpan,
      ),
    );
  }

  static WidgetSpan _lottieSpan(String emoji, [double? size]) {
    return WidgetSpan(
      child: AnimatedEmojiLottieView(
        emoji: AnimatedEmoji.fromGlyph(emoji)!,
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
