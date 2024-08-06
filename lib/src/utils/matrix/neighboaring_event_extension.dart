import 'package:matrix/matrix.dart';

import 'is_display_event_extension.dart';

extension NeighboringDisplayEvents on Timeline {
  Event? getPreviousDisplayEvent(int index) {
    Event? previousEvent;
    int previousEventIndex = index;
    do {
      previousEventIndex++;
      if (previousEventIndex < events.length) {
        previousEvent = events[previousEventIndex].getDisplayEvent(this);
      } else {
        previousEvent = null;
      }
    } while (previousEventIndex < events.length &&
        !(previousEvent?.shouldDisplayEvent ?? false));

    return previousEvent;
  }

  Event? getNextDisplayEvent(int index) {
    Event? nextEvent;
    int nextEventIndex = index;
    do {
      nextEventIndex--;
      if (nextEventIndex >= 0) {
        nextEvent = events[nextEventIndex].getDisplayEvent(this);
      } else {
        nextEvent = null;
      }
    } while (nextEventIndex >= 0 && !(nextEvent?.shouldDisplayEvent ?? false));

    return nextEvent;
  }
}
