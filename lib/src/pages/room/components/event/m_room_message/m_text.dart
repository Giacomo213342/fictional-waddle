import 'package:flutter/material.dart' hide Element, Text;

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:linkify/linkify.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../theme/poly_colors.dart';
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
    final dom = _linkifyTree(parsed.documentElement!);

    return Html.fromElement(
      documentElement: dom,
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
      },
      onlyRenderTheseTags: MatrixHtmlTags.allowed,
      extensions: const [
        TableHtmlExtension(),
        SvgHtmlExtension(),
      ],
      shrinkWrap: true,
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        }
      },
    );
  }

  Element _linkifyTree(Element element) {
    final nodes = element.nodes;
    if (!element.hasChildNodes()) {
      if (element is Text) {
        return _linkifyTextNode(element as Text);
      }
      return element;
    }
    for (int i = 0; i < element.nodes.length; i++) {
      final node = nodes[i];
      if (node is Element) {
        final newNode = _linkifyTree(node);
        element.nodes[i] = newNode;
      } else if (node is Text) {
        element.nodes[i] = _linkifyTextNode(node);
      }
    }
    return element;
  }

  Element _linkifyTextNode(Text node) {
    final linkified = linkify(
      node.text,
      options: const LinkifyOptions(
        humanize: false,
        looseUrl: true,
        defaultToHttps: true,
      ),
    );
    final newNode = Element.tag('span');
    for (final element in linkified) {
      if (element is TextElement) {
        newNode.nodes.add(Text(element.text));
      } else if (element is LinkableElement) {
        final anchor = Element.tag('a');
        anchor.attributes['href'] = element.url;
        anchor.nodes.add(Text(element.originText));
        newNode.nodes.add(anchor);
      }
    }
    return newNode;
  }
}
