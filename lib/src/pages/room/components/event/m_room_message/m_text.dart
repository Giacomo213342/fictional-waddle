import 'package:flutter/material.dart' hide Element, Text;

import 'package:matrix/matrix.dart';

import '../../../../../widgets/matrix/html/polycule_html_view.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
    required this.event,
    this.globalKeyRegistryKey,
  });

  final Event event;
  final String? globalKeyRegistryKey;

  @override
  Widget build(BuildContext context) {
    String html;
    if (event.isRichMessage) {
      html = event.formattedText;
    } else {
      html = event.body.replaceAll('\n', r'<br />');
    }

    // in case the message was redacted or similar
    if (html.isEmpty) {
      html = event.calcLocalizedBodyFallback(
        const MatrixDefaultLocalizations(),
        hideReply: true,
        hideEdit: false,
      );
    }

    if (event.messageType == MessageTypes.Emote) {
      // Unicode Bullet
      html = '\u2022 $html';
    }
    return PolyculeHtmlView(
      html: html,
      globalKeyTag: globalKeyRegistryKey ?? event.eventId,
      event: event,
    );
  }
}
