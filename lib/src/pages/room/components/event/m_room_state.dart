import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../widgets/matrix/scopes/timeline_scope.dart';
import '../../../../utils/matrix/polycule_display_event_extension.dart';

class RoomState extends StatelessWidget {
  const RoomState({super.key});

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context)
        .event
        .resolvePolyculeDisplayEvent(TimelineScope.of(context).timeline)
        .event;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: FutureBuilder<String>(
        future: event.calcLocalizedBody(AppLocalizations.of(context).matrix),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ??
                event.calcLocalizedBodyFallback(
                  AppLocalizations.of(context).matrix,
                ),
          );
        },
      ),
    );
  }
}
