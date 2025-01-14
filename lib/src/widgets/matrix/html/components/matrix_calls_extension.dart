import 'package:flutter/material.dart';

import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/link.dart';

import '../../../../../l10n/generated/app_localizations.dart';

class MatrixCallsExtension extends HtmlExtension {
  const MatrixCallsExtension();

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
    final uri = Uri.tryParse(attribute);
    return uri != null &&
        uri.scheme == 'io.element.call' &&
        uri.queryParameters.containsKey(
          'url',
        );
  }

  @override
  InlineSpan build(ExtensionContext context) {
    final element = context.styledElement!.element!;

    final attribute = context.attributes['href'] ?? element.text;

    Uri? uri = Uri.tryParse(attribute);
    final query = uri?.queryParameters['url'];
    if (uri?.scheme == 'io.element.call' && query != null) {
      uri = Uri.tryParse(Uri.decodeComponent(query));
    }

    String? roomId;
    if (uri != null) {
      final fragmentUri = Uri.tryParse(uri.fragment);
      final parameter = fragmentUri?.queryParameters['roomId'];

      if (parameter != null) {
        roomId = Uri.decodeComponent(parameter);
      }
    }

    return WidgetSpan(
      alignment: PlaceholderAlignment.middle,
      child: Link(
        uri: uri,
        builder: (context, followLink) => GestureDetector(
          onTap: followLink,
          child: Chip(
            label: Text(AppLocalizations.of(context).joinMatrixCall),
            onDeleted: roomId != null ? () {} : null,
            deleteIcon: const Icon(Icons.video_call),
            deleteButtonTooltipMessage: roomId != null
                ? AppLocalizations.of(context).matrixCallTooltip(roomId)
                : null,
          ),
        ),
      ),
    );
  }
}
