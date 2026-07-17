import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../../../utils/matrix/polycule_display_event_extension.dart';
import '../../../../utils/matrix/call_event_summary.dart';

class EventFallbackText extends StatelessWidget {
  const EventFallbackText({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context)
        .event
        .resolvePolyculeDisplayEvent(TimelineScope.of(context).timeline)
        .event;
    if (isMatrixCallSignalingEventType(event.type)) {
      final sender = event.senderFromMemoryOrFallback.calcDisplayname(
        i18n: AppLocalizations.of(context).matrix,
      );
      return Text(
        matrixCallLifecycleKind(event.type) == null
            ? 'Call in progress'
            : matrixCallEventSummary(
                event,
                senderName: sender,
                timeline: TimelineScope.of(context).timeline,
              ),
      );
    }
    return FutureBuilder(
      future: event.calcLocalizedBody(AppLocalizations.of(context).matrix),
      builder: (context, snapshot) => Text(
        snapshot.data ??
            event.calcLocalizedBodyFallback(
              AppLocalizations.of(context).matrix,
            ),
      ),
    );
  }
}
