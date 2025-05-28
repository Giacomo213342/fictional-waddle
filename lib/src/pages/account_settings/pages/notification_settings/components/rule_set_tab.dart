import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import 'push_rule_tile.dart';

class RuleSetTab extends StatelessWidget {
  const RuleSetTab({super.key, this.rules});

  final List<PushRule>? rules;

  @override
  Widget build(BuildContext context) {
    final rules = this.rules;
    if (rules == null) {
      return ListTile(
        leading: const Icon(Icons.info),
        title: Text(AppLocalizations.of(context).noPushRules),
      );
    }
    return ListView.builder(
      itemCount: rules.length,
      itemBuilder: (context, index) => PushRuleTile(
        rule: rules[index],
      ),
    );
  }
}
