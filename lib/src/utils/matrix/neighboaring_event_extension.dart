import 'package:matrix/matrix.dart';

import 'is_display_event_extension.dart';
import 'polycule_display_event_extension.dart';

extension NeighboringDisplayEvents on Timeline {
  int indexOfLogicalEvent(Event event) => events.indexWhere(
        (candidate) =>
            candidate.matchesEventOrTransactionId(event.eventId) ||
            candidate.matchesEventOrTransactionId(event.transactionId) ||
            event.matchesEventOrTransactionId(candidate.eventId) ||
            event.matchesEventOrTransactionId(candidate.transactionId),
      );

  Event? getPreviousDisplayEvent(int index) {
    Event? previousEvent;
    int previousEventIndex = index;
    do {
      previousEventIndex++;
      if (previousEventIndex < events.length) {
        previousEvent =
            events[previousEventIndex].resolvePolyculeDisplayEvent(this).event;
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
        nextEvent =
            events[nextEventIndex].resolvePolyculeDisplayEvent(this).event;
      } else {
        nextEvent = null;
      }
    } while (nextEventIndex >= 0 && !(nextEvent?.shouldDisplayEvent ?? false));

    return nextEvent;
  }
}
