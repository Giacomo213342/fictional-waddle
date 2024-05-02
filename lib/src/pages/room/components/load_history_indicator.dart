import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

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

    if (!timeline.isRequestingHistory) {
      timeline.requestHistory();
    }
    return const AsciiProgressIndicator();
  }
}
