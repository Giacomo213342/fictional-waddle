import 'package:flutter_test/flutter_test.dart';
import 'package:polycule/src/pages/room/components/membership/join.dart';

void main() {
  test('latest shortcut follows distance from reversed-list origin', () {
    expect(
      shouldShowLatestMessagesShortcut(
        pixels: 150,
        viewportDimension: 800,
      ),
      isFalse,
    );
    expect(
      shouldShowLatestMessagesShortcut(
        pixels: 540,
        viewportDimension: 800,
      ),
      isTrue,
    );
  });

  test('loaded event offset is estimated in both timeline directions', () {
    expect(
      estimateReversedTimelineOffset(
        eventIndex: 0,
        eventCount: 101,
        maxScrollExtent: 10000,
      ),
      0,
    );
    expect(
      estimateReversedTimelineOffset(
        eventIndex: 25,
        eventCount: 101,
        maxScrollExtent: 10000,
      ),
      2500,
    );
    expect(
      estimateReversedTimelineOffset(
        eventIndex: 100,
        eventCount: 101,
        maxScrollExtent: 10000,
      ),
      10000,
    );
  });

  test('initial cached-history reveal stays deliberately tiny', () {
    expect(initialHistoryRevealDuration, const Duration(milliseconds: 80));
    expect(initialHistoryRevealDelay(1), const Duration(milliseconds: 10));
    expect(initialHistoryRevealDelay(100), const Duration(milliseconds: 80));
  });
}
