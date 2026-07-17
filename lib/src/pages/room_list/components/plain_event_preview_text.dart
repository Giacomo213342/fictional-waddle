import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../utils/matrix/poll_event.dart';
import '../../../utils/matrix/call_event_summary.dart';
import '../../../widgets/matrix/scopes/event_scope.dart';

class PlainEventPreviewText extends StatelessWidget {
  const PlainEventPreviewText({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;

    if (isMatrixCallSignalingEventType(event.type)) {
      final sender = event.senderFromMemoryOrFallback.calcDisplayname(
        i18n: AppLocalizations.of(context).matrix,
      );
      return Text(
        matrixCallLifecycleKind(event.type) == null
            ? 'Call in progress'
            : matrixCallEventSummary(event, senderName: sender),
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    if (event.isPollStart) {
      final sender = event.senderFromMemoryOrFallback.calcDisplayname(
        i18n: AppLocalizations.of(context).matrix,
      );
      return Text(
        '$sender: Poll: ${event.pollQuestion ?? 'Poll'}',
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      );
    }

    return FutureBuilder(
      future: event.calcLocalizedBody(
        AppLocalizations.of(context).matrix,
        hideReply: true,
        hideEdit: true,
        withSenderNamePrefix: true,
        removeMarkdown: true,
        plaintextBody: true,
      ),
      builder: (context, snapshot) {
        final text = snapshot.data ??
            event.calcLocalizedBodyFallback(
              AppLocalizations.of(context).matrix,
              hideReply: true,
              hideEdit: true,
              withSenderNamePrefix: true,
              removeMarkdown: true,
              plaintextBody: true,
            );
        return Text(
          text
              // unicode bullet
              .replaceAll('\n', ' \u2022 '),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        );
      },
    );
  }
}
