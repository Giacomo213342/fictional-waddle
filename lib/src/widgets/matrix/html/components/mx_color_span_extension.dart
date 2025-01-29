import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';

import '../../../../theme/poly_colors.dart';

const _kMxColorAttribute = 'data-mx-color';

class MxColorSpanExtension extends HtmlExtension {
  const MxColorSpanExtension();

  @override
  Set<String> get supportedTags => {'span'};

  @override
  bool matches(ExtensionContext context) {
    return supportedTags.contains(context.elementName) &&
        context.attributes.containsKey(_kMxColorAttribute);
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final text = context.element?.text;
    final buildContext = context.buildContext;
    final colorAttribute = context.attributes[_kMxColorAttribute];

    if (text == null || buildContext == null || colorAttribute == null) {
      return TextSpan(text: context.innerHtml);
    }

    final color = PolyColors.parseCss(colorAttribute);

    final style = DefaultTextStyle.of(buildContext);

    return TextSpan(
      text: text,
      style: style.style.copyWith(
        color: color,
      ),
    );
  }
}
