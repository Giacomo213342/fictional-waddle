import 'package:html/dom.dart';
import 'package:linkify/linkify.dart';
import 'package:matrix/matrix.dart';

import '../widgets/matrix/client_manager/client_manager.dart';

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
        const MatrixLinkifier(),
        const UrlLinkifier(),
        const EmailLinkifier(),
      ],
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
      } else {
        Logs().e(
          'Unable to match linkify element of type ${element.runtimeType}',
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

    for (var element in elements) {
      if (element is TextElement) {
        final result = element.text.parseIdentifierIntoParts();

        if (result == null) {
          list.add(element);
        } else {
          String uri = result.toMatrixToUrl();
          String text = result.primaryIdentifier;

          list.add(LinkableElement(text, uri));
        }
      } else {
        list.add(element);
      }
    }

    return list;
  }
}
