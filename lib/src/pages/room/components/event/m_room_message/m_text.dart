import 'package:flutter/material.dart' hide Element, Text;

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../../widgets/matrix/html/polycule_html_view.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';

class TextMessage extends StatelessWidget {
  const TextMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    String html;
    if (event.isRichMessage) {
      html = event.formattedText;
    } else {
      html = event.body.replaceAll('\n', r'<br />');
    }

    // in case the message was redacted or similar
    if (html.isEmpty) {
      html = event.calcLocalizedBodyFallback(
        AppLocalizations.of(context).matrix,
        hideReply: true,
        hideEdit: false,
      );
    }

    if (event.messageType == MessageTypes.Emote) {
      // Unicode Bullet
      html = ' \u2022 $html';
    }
    return PolyculeHtmlView(
      html: html,
      event: event,
    );
  }
}
