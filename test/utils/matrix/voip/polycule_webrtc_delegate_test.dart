import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/utils/matrix/voip/polycule_webrtc_delegate.dart';

void main() {
  group('configurePeerConnection', () {
    test('leaves normal ICE policy untouched', () {
      final source = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:example.org'},
        ],
        'sdpSemantics': 'unified-plan',
      };

      final result = configurePeerConnection(source, relayOnly: false);

      expect(result.value, equals(source));
      expect(result.value, isNot(same(source)));
      expect(result.value, isNot(contains('iceTransportPolicy')));
      expect(result.iceServerCount, 1);
      expect(result.turnServerCount, 0);
      expect(result.usesFallbackStun, isFalse);
      expect(result.relayUnavailable, isFalse);
    });

    test('uses the Matrix fallback STUN server without homeserver ICE', () {
      final result = configurePeerConnection(
        {'iceServers': <Object>[]},
        relayOnly: false,
      );

      expect(result.value, isNot(contains('iceTransportPolicy')));
      expect(result.value['iceServers'], [
        {
          'urls': [matrixFallbackStunServer],
        },
      ]);
      expect(result.usesFallbackStun, isTrue);
      expect(result.relayUnavailable, isFalse);
    });

    test('forces relay ICE when proxy calls are enabled', () {
      final result = configurePeerConnection(
        {
          'iceServers': [
            {
              'urls': ['stun:example.org', 'turns:relay.example.org:443'],
            },
          ],
        },
        relayOnly: true,
      );

      expect(result.value['iceTransportPolicy'], 'relay');
      expect(result.turnServerCount, 1);
      expect(result.usesFallbackStun, isFalse);
      expect(result.relayUnavailable, isFalse);
    });

    test('reports a missing TURN relay without allowing direct fallback', () {
      final result = configurePeerConnection(
        {
          'iceServers': [
            {'urls': 'stun:example.org'},
          ],
        },
        relayOnly: true,
      );

      expect(result.value['iceTransportPolicy'], 'relay');
      expect(result.usesFallbackStun, isFalse);
      expect(result.relayUnavailable, isTrue);
    });
  });

  group('containsTurnServer', () {
    test('accepts both TURN URL spellings and rejects STUN-only lists', () {
      expect(
        containsTurnServer([
          {'url': 'turn:relay.example.org'},
        ]),
        isTrue,
      );
      expect(
        containsTurnServer([
          {
            'urls': ['stun:example.org', 'turns:relay.example.org:443'],
          },
        ]),
        isTrue,
      );
      expect(
        containsTurnServer([
          {'urls': 'stun:example.org'},
        ]),
        isFalse,
      );
    });
  });
}
