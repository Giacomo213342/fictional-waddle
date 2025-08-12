import 'package:html/dom.dart';
import 'package:linkify/linkify.dart';
import 'package:matrix/matrix.dart';

import '../widgets/matrix/html/components/animated_emoji_extension.dart';
import 'error_logger.dart';
import 'matrix_to_extension.dart';

extension LinkifyTree on Node {
  Node linkify() {
    final node = this;

    if (node is Text) {
      return node._linkifyText();
    }
    if (node is Element || node is Document || node is DocumentFragment) {
      return node._linkifyTree();
    }
    // Comment, DocumentType
    return node;
  }

  Node _linkifyTree() {
    final nodes = this.nodes;
    if (!hasChildNodes()) {
      return this;
    }
    for (int i = 0; i < nodes.length; i++) {
      nodes[i] = nodes[i].linkify();
    }
    return this;
  }
}

extension LinkifyText on Text {
  Element _linkifyText() {
    final linkified = linkify(
      text,
      options: const LinkifyOptions(
        humanize: false,
        looseUrl: false,
        defaultToHttps: true,
      ),
      linkifiers: [
        const MatrixCallLinkifier(),
        const MatrixLinkifier(),
        const UrlLinkifier(),
        const EmailLinkifier(),
      ],
    );
    final newNode = Element.tag('span');
    for (final element in linkified) {
      switch (element) {
        case TextElement():
          for (final word in element.text.split(' ')) {
            if (word == '[matrix]') {
              newNode.nodes.add(Element.tag('matrix-logo'));
              newNode.nodes.add(Text(' '));
            } else {
              newNode.nodes
                  .addAll(AnimatedEmojiExtension.emojifyTextNode(word));
              newNode.nodes.add(Text(' '));
            }
          }
          newNode.nodes.removeLast();
        case LinkableElement():
          final anchor = Element.tag('a');
          anchor.attributes['href'] = element.url;
          anchor.nodes.add(Text(element.originText));
          newNode.nodes.add(anchor);
        default:
          ErrorLogger().captureStackTrace(
            'Unable to match linkify element of type ${element.runtimeType}',
            null,
          );
      }
    }
    return newNode;
  }
}

class MatrixLinkifier extends Linkifier {
  const MatrixLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    for (final element in elements) {
      if (element is TextElement) {
        for (final word in element.text.split(' ')) {
          final result = word.parseIdentifierIntoParts();

          if (result == null ||
              // do not interpret !XXXXX as room unless other properties set
              (result.primaryIdentifier.startsWith('!') &&
                  result.action == null &&
                  result.via.isEmpty &&
                  result.secondaryIdentifier == null)) {
            list.add(TextElement(word));
          } else {
            String uri = result.toMatrixToUrl();
            String text = result.primaryIdentifier;

            list.add(LinkableElement(text, uri));
          }
          list.add(TextElement(' '));
        }
        list.removeLast();
      } else {
        list.add(element);
      }
    }

    return list;
  }
}

class MatrixCallLinkifier extends Linkifier {
  const MatrixCallLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    for (var element in elements) {
      if (element is TextElement) {
        String? link = element.text;
        bool? isElementCallLink;

        if (link.startsWith('io.element.call')) {
          final prefixedUri = Uri.tryParse(link);
          final url = prefixedUri?.queryParameters['url'];
          if (prefixedUri?.scheme == 'io.element.call' && url != null) {
            isElementCallLink = true;
            link = Uri.decodeComponent(url);
          }
        }
        final uri = Uri.tryParse(link);

        // check whether it's an Element Call link
        isElementCallLink ??= uri?.host == 'call.element.io';

        if (!isElementCallLink || uri == null) {
          list.add(element);
        } else {
          String uri = Uri(
            scheme: 'io.element.call',
            path: '/',
            queryParameters: {
              'url': Uri.encodeComponent(link),
            },
          ).toString();
          String text = link;

          list.add(LinkableElement(text, uri));
        }
      } else {
        list.add(element);
      }
    }

    return list;
  }
}
