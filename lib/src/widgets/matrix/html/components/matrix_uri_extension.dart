import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../mxid_preview_pile.dart';

class MatrixUriExtension extends HtmlExtension {
  MatrixUriExtension({
    required this.client,
    this.room,
  });

  final Client client;
  final Room? room;

  @override
  Set<String> get supportedTags => {'a'};

  @override
  bool matches(ExtensionContext context) {
    if (!supportedTags.contains(context.elementName)) {
      return false;
    }

    final attribute = context.attributes['href'];
    if (attribute == null) {
      return false;
    }

    return attribute.parseIdentifierIntoParts() != null;
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement!.element!;

    final attribute = context.attributes['href'] ?? element.text;

    final identifiers = attribute.parseIdentifierIntoParts();

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: GestureDetector(
        onTap: () {
          if (identifiers == null) {
            return;
          }
          String link = identifiers.primaryIdentifier;
          final secondary = identifiers.secondaryIdentifier;
          if (secondary is String) {
            link += '/$secondary';
          }
          final query = identifiers.queryString;
          if (query is String) {
            link += '?$query';
          }
          context.buildContext?.push('/${Uri.encodeComponent(link)}');
        },
        child: MxidPreviewPile(
          client: client,
          room: room,
          mxid: identifiers?.primaryIdentifier,
          secondary: identifiers?.secondaryIdentifier,
          via: identifiers?.via,
          fallback: element.text,
        ),
      ),
    );
  }
}
