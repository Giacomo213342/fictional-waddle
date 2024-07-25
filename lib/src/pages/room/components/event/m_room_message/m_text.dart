import 'package:flutter/material.dart' hide Element, Text;

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../theme/fonts.dart';
import '../../../../../theme/poly_colors.dart';
import '../../../../../utils/linkify_node.dart';
import '../../../../../utils/matrix/matrix_html_tags.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final Style zeroPaddingStyle = Style(
      display: Display.inline,
      padding: HtmlPaddings(
        blockEnd: HtmlPadding(0),
        inlineEnd: HtmlPadding(0),
        left: HtmlPadding(0),
        inlineStart: HtmlPadding(0),
        blockStart: HtmlPadding(0),
        right: HtmlPadding(0),
        top: HtmlPadding(0),
        bottom: HtmlPadding(0),
      ),
    );

    double textScaleFactor = 1;
    if (event.onlyEmotes) {
      textScaleFactor = 4;
    }

    final linkStyle = Style(
      color: PolyColors.cyan,
      textDecoration: TextDecoration.none,
    );

    String html;
    if (event.isRichMessage) {
      html = event.formattedText;
    } else {
      html = event.text;
    }

    if (event.messageType == MessageTypes.Emote) {
      // Unicode Bullet
      html = '\u2022 $html';
    }
    final parsed = parse(html, generateSpans: true);
    final dom = parsed.linkify();

    return Html.fromDom(
      document: dom as Document,
      style: {
        'body': zeroPaddingStyle,
        'a': linkStyle,
        'h1, h2, h3, h4, h5, h6': zeroPaddingStyle,
        // Add maxLines restriction for reply message widget
        'html': zeroPaddingStyle.copyWith(
          textOverflow: TextOverflow.fade,
          fontSize: FontSize(
            (DefaultTextStyle.of(context).style.fontSize ?? 12) *
                textScaleFactor,
          ),
        ),
        'pre': Style(
          display: Display.block,
          margin: Margins.symmetric(horizontal: 0, vertical: 2),
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          textOverflow: TextOverflow.visible,
          padding: HtmlPaddings.all(8),
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        'code': Style(
          // we use Noto Mono for code blocks. Additionally add Emoji support
          fontFamily: PolyculeFonts.notoSansMono.name,
          fontFamilyFallback: [
            PolyculeFonts.notoColorEmoji.name,
            PolyculeFonts.notoSans.name,
          ],
          // prevent inline markdown
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
      },
      onlyRenderTheseTags: MatrixHtmlTags.allowed,
      extensions: const [
        TableHtmlExtension(),
        SvgHtmlExtension(),
      ],
      shrinkWrap: false,
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          launchUrl(Uri.parse(url));
        }
      },
    );
  }
}
