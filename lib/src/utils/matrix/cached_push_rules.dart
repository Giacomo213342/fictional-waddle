Set<String> mutedRoomIdsFromPushRules(Map<String, dynamic>? content) {
  final global = content?['global'];
  if (global is! Map) return const {};
  final overrides = global['override'];
  if (overrides is! List) return const {};

  final mutedRoomIds = <String>{};
  for (final rule in overrides.whereType<Map>()) {
    final ruleId = rule['rule_id'];
    if (rule['enabled'] == false || ruleId is! String) continue;
    final actions = rule['actions'];
    if (actions is! List) continue;
    final effectiveActions = actions.where(
      (action) => action != 'dont_notify' && action != 'coalesce',
    );
    if (effectiveActions.isEmpty) mutedRoomIds.add(ruleId);
  }
  return mutedRoomIds;
}
