import 'package:flutter_test/flutter_test.dart';

import 'package:polycule/src/pages/room_list/room_list_ordering.dart';

void main() {
  test('normal rooms remain ahead of low-priority rooms', () {
    final rooms = normalBeforeLowPriority(
      const [
        (id: 'low-new', lowPriority: true),
        (id: 'normal-new', lowPriority: false),
        (id: 'normal-old', lowPriority: false),
        (id: 'low-old', lowPriority: true),
      ],
      isLowPriority: (room) => room.lowPriority,
    );

    expect(
      rooms.map((room) => room.id),
      ['normal-new', 'normal-old', 'low-new', 'low-old'],
    );
  });

  test('new low-priority activity leads only its own section', () {
    final rooms = normalBeforeLowPriority(
      const [
        (id: 'low-with-new-message', lowPriority: true),
        (id: 'normal', lowPriority: false),
        (id: 'low-older', lowPriority: true),
      ],
      isLowPriority: (room) => room.lowPriority,
    );

    expect(
      rooms.map((room) => room.id),
      ['normal', 'low-with-new-message', 'low-older'],
    );
  });
}
