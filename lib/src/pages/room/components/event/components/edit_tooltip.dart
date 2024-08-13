import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/human_date.dart';

class EditTooltip extends StatelessWidget {
  const EditTooltip({super.key, required this.editEvent});

  final Event editEvent;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: editEvent.originServerTs
              .isAfter(DateTime.now().subtract(const Duration(days: 1)))
          ? AppLocalizations.of(context).editedToday(editEvent.originServerTs)
          : AppLocalizations.of(context).editedAt(
              editEvent.originServerTs.humanShortDate(
                context: context,
                fullLength: true,
              ),
            ),
      child: const Icon(Icons.edit),
    );
  }
}
