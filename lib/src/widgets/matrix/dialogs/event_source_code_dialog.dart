import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:html/parser.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../pages/room/components/event/m_room_message_content.dart';
import '../../../pages/room/components/event/quoted_event.dart';
import '../../../pages/room_list/components/plain_event_preview_text.dart';
import '../../polycule_highlight_view.dart';
import '../blur_hash_indicator.dart';
import '../scopes/event_scope.dart';
import '../scopes/matrix_scope.dart';

class EventSourceCodeDialog extends StatelessWidget {
  const EventSourceCodeDialog({super.key});

  static const _intent = '  ';

  Future<void> showDialog({required BuildContext context}) {
    final scope = MatrixScope.captureAll(context);
    return Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (context) => MatrixScope(scope: scope, child: this),
        fullscreenDialog: true,
        barrierDismissible: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    final encoder = const JsonEncoder.withIndent(_intent);
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).eventSourceCode)),
      body: SelectionArea(
        child: ListView(
          children: [
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventRendered),
              expandedAlignment: Alignment.topLeft,
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(2.0),
                    child: RoomMessageContent(),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventQuoted),
              expandedAlignment: Alignment.topLeft,
              children: [
                const QuotedEvent(),
              ],
            ),
            if (event.infoMap.containsKey('xyz.amorgan.blurhash')) ...[
              ExpansionTile(
                title: Text(AppLocalizations.of(context).blurHash),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlurHashIndicator(
                    label: Text(AppLocalizations.of(context).blurHash),
                  ),
                ],
              ),
            ],
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventPreview),
              expandedAlignment: Alignment.topLeft,
              children: [
                const ListTile(
                  leading: Icon(Icons.format_quote),
                  title: PlainEventPreviewText(),
                ),
              ],
            ),
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventSourceBodyRaw),
              expandedAlignment: Alignment.topLeft,
              children: [
                PolyculeHighlightView(
                  event.body,
                  language: event.content.containsKey('formatted_body')
                      ? 'markdown'
                      : 'text',
                ),
              ],
            ),
            if (event.content['format'] == 'org.matrix.custom.html') ...[
              ExpansionTile(
                title: Text(AppLocalizations.of(context).eventSourceBodyHtml),
                expandedAlignment: Alignment.topLeft,
                children: [
                  PolyculeHighlightView(
                    parse(event.formattedText).body!.innerHtml,
                    language: 'xml',
                  ),
                ],
              ),
            ],
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventSourceContent),
              expandedAlignment: Alignment.topLeft,
              children: [
                PolyculeHighlightView(
                  encoder.convert(event.content),
                  language: 'json',
                ),
              ],
            ),
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventSourceJson),
              expandedAlignment: Alignment.topLeft,
              children: [
                PolyculeHighlightView(
                  encoder.convert(event.toJson()),
                  language: 'json',
                ),
              ],
            ),
            if (event.originalSource != null) ...[
              ExpansionTile(
                title: Text(AppLocalizations.of(context).eventSourceOriginal),
                expandedAlignment: Alignment.topLeft,
                children: [
                  PolyculeHighlightView(
                    encoder.convert(event.originalSource?.toJson()),
                    language: 'json',
                  ),
                ],
              ),
            ],
            ExpansionTile(
              title: Text(AppLocalizations.of(context).eventSourceUnsigned),
              expandedAlignment: Alignment.topLeft,
              children: [
                PolyculeHighlightView(
                  encoder.convert(event.unsigned),
                  language: 'json',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
