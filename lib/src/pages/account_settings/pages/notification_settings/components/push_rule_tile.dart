import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/polycule_highlight_view.dart';
import 'default_rule_tile.dart';
import 'pattern_tile.dart';
import 'push_condition_tile.dart';
import 'rule_action_tile.dart';
import 'rule_action_tweaks_tile.dart';

class PushRuleTile extends StatelessWidget {
  const PushRuleTile({super.key, required this.rule});

  static const _intent = '  ';

  final PushRule rule;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(rule.ruleId),
      children: [
        if (rule.pattern != null) ...[
          PatternTile(pattern: rule.pattern!),
          const Divider(),
        ],
        ...?rule.conditions
            ?.map((condition) => PushConditionTile(condition: condition)),
        if (rule.conditions != null) const Divider(),
        ...rule.actions.map((action) {
          if (action is String) {
            return RuleActionTile(action: action);
          } else if (action is Map<String, Object?>) {
            return RuleActionTweaksTile(action: action);
          } else {
            return RuleActionTile(action: action.toString());
          }
        }),
        if (rule.actions.isNotEmpty) const Divider(),
        if (rule.default$) const DefaultRuleTile(),
        SwitchListTile(
          title: Text(AppLocalizations.of(context).pushRuleEnabled),
          value: rule.enabled,
          onChanged: null,
        ),
        ExpansionTile(
          title: Text(AppLocalizations.of(context).viewSourceCode),
          children: [
            PolyculeHighlightView(
              const JsonEncoder.withIndent(_intent).convert(rule.toJson()),
              language: 'json',
            ),
          ],
        ),
      ],
    );
  }
}
