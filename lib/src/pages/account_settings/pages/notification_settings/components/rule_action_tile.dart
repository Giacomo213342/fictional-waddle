import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class RuleActionTile extends StatelessWidget {
  const RuleActionTile({super.key, required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    return switch (action) {
      'notify' => ListTile(
          leading: const Icon(Icons.notifications_active),
          title: Text(AppLocalizations.of(context).actionNotify),
        ),
      'dont_notify' => ListTile(
          leading: const Icon(Icons.notifications_paused),
          title: Text(AppLocalizations.of(context).actionDontNotify),
        ),
      _ => ListTile(
          leading: const Icon(Icons.question_mark),
          title: Text(AppLocalizations.of(context).unknownAction(action)),
        )
    };
  }
}
