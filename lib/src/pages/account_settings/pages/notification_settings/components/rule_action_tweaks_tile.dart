import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class RuleActionTweaksTile extends StatelessWidget {
  const RuleActionTweaksTile({super.key, required this.action});

  final Map<String, Object?> action;

  @override
  Widget build(BuildContext context) {
    final tweak = action['set_tweak'];
    final tweakLabel = switch (tweak) {
      'sound' => AppLocalizations.of(context).notificationTweakSound,
      'highlight' => AppLocalizations.of(context).notificationTweakHighlight,
      _ =>
        AppLocalizations.of(context).unknownNotificationTweak(tweak.toString),
    };
    final value = switch (action['value']) {
      null || true || 'true' => true,
      false || 'false' => false,
      'default' || _ => null
    };
    final valueLabel = switch (value) {
      true => AppLocalizations.of(context).tweakEnabled,
      false => AppLocalizations.of(context).tweakDisabled,
      null => AppLocalizations.of(context).tweakDefault,
    };

    return ListTile(
      title: Semantics(
        value: value == null ? null : valueLabel,
        child: Text(
          tweakLabel,
          style: TextStyle(
            decoration: value == false ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
      subtitle: value == null ? Text(valueLabel) : null,
    );
  }
}
