import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';

import '../../../polycule_highlight_view.dart';

final _languageRegex = RegExp(r'^language-(\w+)$');

class CodeBlockExtension extends HtmlExtension {
  @override
  Set<String> get supportedTags => {'pre'};

  @override
  bool matches(ExtensionContext context) {
    if (!supportedTags.contains(context.elementName)) {
      return false;
    }

    // only match `pre` tags containing code blocks - any other one is handled
    // by the HTML renderer itself
    return (context.styledElement?.children.singleOrNull?.name == 'code');
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement!.element!;

    final classes = element.children.singleOrNull?.classes;

    final language = classes
        ?.map((c) => _languageRegex.firstMatch(c))
        .map((match) => match?.group(1))
        .whereType<String>()
        .singleOrNull;

    final text = element.text.trimRight();

    return WidgetSpan(
      child: PolyculeHighlightView(text, language: language),
    );
  }
}
