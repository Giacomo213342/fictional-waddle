import 'package:flutter_test/flutter_test.dart';

import 'package:polycule/src/utils/matrix/poll_wire_format.dart';

void main() {
  test('stable poll responses use m.selections', () {
    final content = buildPollResponseContent(
      pollEventId: r'$poll',
      answerId: 'yes',
      unstable: false,
    );

    expect(content['m.selections'], ['yes']);
    expect(content, isNot(contains('org.matrix.msc3381.poll.response')));
    expect(content['m.relates_to'], {
      'rel_type': 'm.reference',
      'event_id': r'$poll',
    });
  });

  test('unstable poll responses use the MSC3381 response body', () {
    final content = buildPollResponseContent(
      pollEventId: r'$poll',
      answerId: 'no',
      unstable: true,
    );

    expect(content['org.matrix.msc3381.poll.response'], {
      'answers': ['no'],
    });
    expect(content, isNot(contains('m.selections')));
  });
}
