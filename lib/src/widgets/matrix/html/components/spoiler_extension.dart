import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';

import '../../../../../l10n/generated/app_localizations.dart';

const _kSpoilerAttribute = 'data-mx-spoiler';
const _kSpoilerPlaceholder = '\u2022';

class SpoilerExtension extends HtmlExtension {
  SpoilerExtension({required this.openNotices, required this.onToggleNotice});

  final Set<String?> openNotices;
  final ValueChanged<String?> onToggleNotice;

  @override
  Set<String> get supportedTags => {'span'};

  @override
  bool matches(ExtensionContext context) {
    if (!supportedTags.contains(context.elementName)) {
      return false;
    }

    return (context.attributes.containsKey(_kSpoilerAttribute));
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement!.element!;

    final text = element.text;
    String? notice = context.attributes[_kSpoilerAttribute];
    if (notice is String && notice.isEmpty) {
      notice = null;
    }

    final showContent = openNotices.contains(notice);

    final style = TextStyle(
      backgroundColor: Theme.of(context.buildContext!)
          .colorScheme
          .tertiaryContainer
          .withValues(alpha: .5),
    );

    final recognizer = TapGestureRecognizer()
      ..onTap = () {
        onToggleNotice.call(notice);
      };

    if (showContent) {
      return TextSpan(
        text: text,
        style: style,
        recognizer: recognizer,
      );
    }

    final noticeText = notice is String
        ? AppLocalizations.of(context.buildContext!).contentNotice(notice)
        : AppLocalizations.of(context.buildContext!).contentNoticeFallback;

    final placeholder = text.length > noticeText.length
        ? List.generate(
            text.length - noticeText.length,
            (_) => _kSpoilerPlaceholder,
          ).join()
        : '';

    return TextSpan(
      children: [
        TextSpan(
          text: noticeText,
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            fontFeatures: [
              FontFeature.enable('smcp'),
            ],
          ),
          recognizer: recognizer,
        ),
        TextSpan(
          text: placeholder,
          recognizer: recognizer,
        ),
      ],
      style: style,
      recognizer: recognizer,
    );
  }
}
