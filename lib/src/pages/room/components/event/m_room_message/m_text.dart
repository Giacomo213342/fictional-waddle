import 'package:flutter/material.dart' hide Element, Text;

import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_svg/flutter_html_svg.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' hide HtmlParser;
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../theme/fonts.dart';
import '../../../../../theme/poly_colors.dart';
import '../../../../../utils/linkify_node.dart';
import '../../../../../utils/matrix/matrix_html_tags.dart';
import 'html/code_block_extension.dart';
import 'html/matrix_calls_extension.dart';
import 'html/matrix_uri_extension.dart';
import 'html/mxc_image_extension.dart';
import 'html/spoiler_extension.dart';

final _eventKeyRegistry = <String, GlobalKey<State<HtmlParser>>>{};

class TextMessage extends StatefulWidget {
  const TextMessage({
    super.key,
    required this.event,
    this.globalKeyRegistryKey,
  });

  final Event event;
  final String? globalKeyRegistryKey;

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  Set<String?> openContentNotices = {};

  @override
  void didUpdateWidget(covariant TextMessage oldWidget) {
    if (oldWidget.event.formattedText != widget.event.formattedText ||
        oldWidget.event.text != widget.event.text) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

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
    if (widget.event.onlyEmotes) {
      textScaleFactor = 4;
    }
    final fontSize =
        (DefaultTextStyle.of(context).style.fontSize ?? 12) * textScaleFactor;

    final linkStyle = Style(
      color: PolyColors.cyan,
      textDecoration: TextDecoration.none,
    );

    String html;
    if (widget.event.isRichMessage) {
      html = widget.event.formattedText;
    } else {
      html = widget.event.calcLocalizedBodyFallback(
        const MatrixDefaultLocalizations(),
      );
    }

    // in case the message was redacted or similar
    if (html.isEmpty) {
      html = widget.event.calcLocalizedBodyFallback(
        const MatrixDefaultLocalizations(),
        hideReply: true,
        hideEdit: false,
      );
    }

    if (widget.event.messageType == MessageTypes.Emote) {
      // Unicode Bullet
      html = '\u2022 $html';
    }
    final parsed = parse(html, generateSpans: true);
    final dom = parsed.linkify() as Document;

    final globalKeyRegistryKey =
        widget.globalKeyRegistryKey ?? widget.event.eventId;
    return Html.fromDom(
      anchorKey: _eventKeyRegistry[html + globalKeyRegistryKey] ??=
          GlobalKey<State<HtmlParser>>(),
      document: dom,
      style: {
        'body': zeroPaddingStyle,
        'a': linkStyle,
        'h1, h2, h3, h4, h5, h6': zeroPaddingStyle.copyWith(
          lineHeight: LineHeight.number(1.5),
        ),
        'h1': Style(
          fontSize: FontSize(fontSize * 2),
          fontWeight: FontWeight.w600,
        ),
        'h2': Style(
          fontSize: FontSize(fontSize * 1.75),
          fontWeight: FontWeight.w500,
        ),
        'h3': Style(
          fontSize: FontSize(fontSize * 1.5),
        ),
        'h4': Style(
          fontSize: FontSize(fontSize * 1.25),
        ),
        'h5': Style(
          fontSize: FontSize(fontSize * 1.25),
        ),
        'h6': Style(
          fontSize: FontSize(fontSize),
        ),
        // Add maxLines restriction for reply message widget
        'html': zeroPaddingStyle.copyWith(
          textOverflow: TextOverflow.fade,
          fontSize: FontSize(fontSize),
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
      extensions: [
        MxcImageExtension(widget.event.room.client),
        ImageExtension(),
        CodeBlockExtension(),
        SpoilerExtension(
          openNotices: openContentNotices,
          onToggleNotice: toggleNotice,
        ),
        const MatrixCallsExtension(),
        MatrixUriExtension(event: widget.event),
        const TableHtmlExtension(),
        const SvgHtmlExtension(),
      ],
      shrinkWrap: false,
      onLinkTap: (url, attributes, element) {
        if (url != null) {
          launchUrl(Uri.parse(url));
        }
      },
    );
  }

  void toggleNotice(String? notice) {
    setState(() {
      if (openContentNotices.contains(notice)) {
        openContentNotices.remove(notice);
      } else {
        openContentNotices.add(notice);
      }
    });
  }
}
