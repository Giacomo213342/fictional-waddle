import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../widgets/ascii_progress_indicator.dart';

class LoadHistoryIndicator extends StatelessWidget {
  const LoadHistoryIndicator({
    super.key,
    required this.timeline,
  });

  final Timeline timeline;

  @override
  Widget build(BuildContext context) {
    if (timeline.events.last.type == EventTypes.RoomCreate) {
      return const SizedBox();
    }

    _requestHistory();

    return VisibilityDetector(
      key: ValueKey(timeline.room.lastEvent?.eventId),
      onVisibilityChanged: (VisibilityInfo info) => _requestHistory(),
      child: const AsciiProgressIndicator(),
    );
  }

  Future<void> _requestHistory() async {
    if (!timeline.isRequestingHistory) {
      await timeline.requestHistory();
    }
  }
}
