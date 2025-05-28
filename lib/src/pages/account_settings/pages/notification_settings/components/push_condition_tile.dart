import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../theme/fonts.dart';

class PushConditionTile extends StatelessWidget {
  const PushConditionTile({super.key, required this.condition});

  final PushCondition condition;

  @override
  Widget build(BuildContext context) {
    if (condition.kind == 'contains_display_name') {
      return ListTile(
        leading:
            Tooltip(message: condition.kind, child: const Icon(Icons.person)),
        title:
            Text(AppLocalizations.of(context).pushConditionContainsDisplayName),
      );
    }
    if (condition.kind == 'sender_notification_permission') {
      return ListTile(
        leading:
            Tooltip(message: condition.kind, child: const Icon(Icons.security)),
        title: Text(
          AppLocalizations.of(context)
              .pushConditionSenderNotificationPermission(
            condition.key.toString(),
          ),
        ),
      );
    }

    return ListTile(
      leading: Tooltip(
        message: condition.kind,
        child: Icon(
          switch (condition.kind) {
            'event_match' => Icons.message,
            'event_property_contains' => Icons.list_alt,
            'event_property_is' => Icons.list_alt,
            'room_member_count' => Icons.numbers,
            _ => Icons.question_mark
          },
        ),
      ),
      title: Text(
        (condition.is$ ?? condition.value ?? condition.pattern).toString(),
        style: TextStyle(
          fontFamily: PolyculeFonts.notoSansMono.name,
        ),
      ),
      subtitle: condition.key == null
          ? null
          : Text(
              condition.key.toString(),
              style: TextStyle(
                fontFamily: PolyculeFonts.notoSansMono.name,
              ),
            ),
    );
  }
}
