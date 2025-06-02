import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../utils/assets.dart';
import '../../../../utils/parent_font_size_extension.dart';

class MatrixLogoExtension extends HtmlExtension {
  const MatrixLogoExtension();

  @override
  Set<String> get supportedTags => {'matrix-logo'};

  @override
  InlineSpan build(ExtensionContext context) {
    final extensionContext = context;
    return WidgetSpan(
      child: Builder(
        builder: (context) {
          final style = DefaultTextStyle.of(context);
          final color = style.style.color;
          final fontSize =
              (extensionContext.tryGetParentFontSize()?.emValue ?? 12) * 1.25;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: fontSize / 12),
            child: SvgPicture.asset(
              Assets.matrixLogo.name,
              height: fontSize,
              colorFilter: color == null
                  ? null
                  : ColorFilter.mode(
                      color,
                      BlendMode.srcIn,
                    ),
            ),
          );
        },
      ),
    );
  }
}
