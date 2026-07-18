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

  group('isGroupCallEligible', () {
    test('accepts joined non-direct rooms with at least three members', () {
      expect(
        isGroupCallEligible(
          membership: Membership.join,
          isDirectChat: false,
          joinedMemberCount: 3,
        ),
        isTrue,
      );
      expect(
        isGroupCallEligible(
          membership: Membership.join,
          isDirectChat: false,
          joinedMemberCount: 12,
        ),
        isTrue,
      );
    });

    test('keeps controls available while a group count is lazy-loaded', () {
      expect(
        isGroupCallEligible(
          membership: Membership.join,
          isDirectChat: false,
          joinedMemberCount: null,
        ),
        isTrue,
      );
    });

    test('rejects direct, non-joined, and undersized rooms', () {
      bool eligible({
        Membership membership = Membership.join,
        bool direct = false,
        int? count = 3,
      }) =>
          isGroupCallEligible(
            membership: membership,
            isDirectChat: direct,
            joinedMemberCount: count,
          );

      expect(eligible(membership: Membership.invite), isFalse);
      expect(eligible(direct: true), isFalse);
      expect(eligible(count: 2), isFalse);
    });
  });
}
