import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fullscreen media pages come from image and video timeline events', () {
    final source = File(
      'lib/src/pages/room/components/event/components/attachment_toolbar.dart',
    ).readAsStringSync();

    expect(source, contains('.timeline.events'));
    expect(source, contains('.where(isFullscreenGalleryEvent)'));
    expect(source, contains('MessageTypes.Image'));
    expect(source, contains('MessageTypes.Video'));
    expect(source, contains('PageView.builder('));
    expect(source, contains('itemCount: widget.events.length'));
    expect(source, contains('EventScope('));
  });

  test('gallery swipe is available only while the image is not zoomed', () {
    final source = File(
      'lib/src/pages/room/components/event/components/attachment_toolbar.dart',
    ).readAsStringSync();

    expect(source, contains('NeverScrollableScrollPhysics'));
    expect(source, contains('PageScrollPhysics'));
    expect(source, contains('panEnabled: _zoomed'));
    expect(source, contains('widget.onZoomChanged(value)'));
  });

  test('timeline navigation follows the currently visible media page', () {
    final source = File(
      'lib/src/pages/room/components/event/components/attachment_toolbar.dart',
    ).readAsStringSync();

    expect(source, contains('final eventId = _event.eventId'));
    expect(source, contains('widget.onNavigateToEvent(eventId)'));
    expect(source, contains('widget.onShare(_event, rect)'));
    expect(source, contains('widget.onDownload(_event, rect)'));
  });
}
