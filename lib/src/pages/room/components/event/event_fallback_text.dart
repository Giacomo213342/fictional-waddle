import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../widgets/matrix/event_scope.dart';
import '../../../../widgets/matrix/timeline_scope.dart';

class EventFallbackText extends StatelessWidget {
  const EventFallbackText({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context)
        .event
        .getDisplayEvent(TimelineScope.of(context).timeline);
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
