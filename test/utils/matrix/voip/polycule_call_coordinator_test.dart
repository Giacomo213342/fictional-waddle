import 'package:flutter_test/flutter_test.dart';
import 'package:matrix/matrix.dart';
import 'package:polycule/src/utils/matrix/voip/polycule_call_coordinator.dart';

void main() {
  group('isOneToOneCallEligible', () {
    test('accepts a joined direct peer room', () {
      expect(
        isOneToOneCallEligible(
          membership: Membership.join,
          remoteUserId: '@peer:example.org',
          localUserId: '@me:example.org',
          joinedMemberCount: 2,
        ),
        isTrue,
      );
    });

    test('allows an unknown lazy-loaded count for a known direct peer', () {
      expect(
        isOneToOneCallEligible(
          membership: Membership.join,
          remoteUserId: '@peer:example.org',
          localUserId: '@me:example.org',
          joinedMemberCount: null,
        ),
        isTrue,
      );
    });

    test('rejects non-joined, self, missing peer and multi-member rooms', () {
      bool eligible({
        Membership membership = Membership.join,
        String? remote = '@peer:example.org',
        int? count = 2,
      }) =>
          isOneToOneCallEligible(
            membership: membership,
            remoteUserId: remote,
            localUserId: '@me:example.org',
            joinedMemberCount: count,
          );

      expect(eligible(membership: Membership.invite), isFalse);
      expect(eligible(remote: null), isFalse);
      expect(eligible(remote: '@me:example.org'), isFalse);
      expect(eligible(count: 4), isFalse);
    });
  });
}
