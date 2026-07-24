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
        ),
        isTrue,
      );
    });

    test('allows a direct peer even when a bridge added room members', () {
      expect(
        isOneToOneCallEligible(
          membership: Membership.join,
          remoteUserId: '@peer:example.org',
          localUserId: '@me:example.org',
        ),
        isTrue,
      );
    });

    test('rejects non-joined, self and missing direct peers', () {
      bool eligible({
        Membership membership = Membership.join,
        String? remote = '@peer:example.org',
      }) =>
          isOneToOneCallEligible(
            membership: membership,
            remoteUserId: remote,
            localUserId: '@me:example.org',
          );

      expect(eligible(membership: Membership.invite), isFalse);
      expect(eligible(remote: null), isFalse);
      expect(eligible(remote: '@me:example.org'), isFalse);
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
