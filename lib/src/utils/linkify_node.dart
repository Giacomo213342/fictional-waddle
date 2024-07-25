import 'package:html/dom.dart';
import 'package:linkify/linkify.dart';

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
