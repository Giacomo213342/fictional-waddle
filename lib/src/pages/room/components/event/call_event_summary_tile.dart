import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../utils/matrix/call_event_summary.dart';
import '../../../../widgets/human_date.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';

class CallEventSummaryTile extends StatelessWidget {
  const CallEventSummaryTile({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    final sender = event.senderFromMemoryOrFallback.calcDisplayname(
      i18n: AppLocalizations.of(context).matrix,
    );
    final kind = matrixCallLifecycleKind(event.type);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            kind == MatrixCallLifecycleKind.hangup ||
                    kind == MatrixCallLifecycleKind.reject
                ? Icons.call_end_outlined
                : Icons.call_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              matrixCallEventSummary(
                event,
                senderName: sender,
                timeline: TimelineScope.of(context).timeline,
              ),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            event.originServerTs.humanShortDate(context: context),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
