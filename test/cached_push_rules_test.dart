import 'package:flutter_test/flutter_test.dart';

import 'package:polycule/src/utils/matrix/cached_push_rules.dart';

void main() {
  test('extracts enabled room mute overrides', () {
    final muted = mutedRoomIdsFromPushRules({
      'global': {
        'override': [
          {
            'rule_id': '!muted:example.org',
            'enabled': true,
            'actions': <Object>[],
          },
          {
            'rule_id': '!disabled:example.org',
            'enabled': false,
            'actions': <Object>[],
          },
          {
            'rule_id': '!not-muted:example.org',
            'enabled': true,
            'actions': ['notify'],
          },
        ],
      },
    });

    expect(muted, {'!muted:example.org'});
  });
}
