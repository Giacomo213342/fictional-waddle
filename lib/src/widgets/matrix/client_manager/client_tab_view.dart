import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import '../../../utils/matrix/active_room_tracker.dart';
import 'components/top/keyboard_aware_top_bar.dart';

class ClientTabView extends StatelessWidget {
  const ClientTabView({super.key, required this.uri, required this.child});

  final Uri uri;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final activeRoomMatch =
        RegExp(r'^/client/\d+/rooms/([^/]+)$').firstMatch(uri.path);
    ActiveRoomTracker.roomId = activeRoomMatch == null
        ? null
        : Uri.decodeComponent(activeRoomMatch.group(1)!);

    return Scaffold(
      body: AdaptiveLayout(
        transitionDuration: const Duration(milliseconds: 300),
        body: SlotLayout(
          config: {
            Breakpoints.smallAndUp: SlotLayout.from(
              key: const Key('body'),
              builder: (context) => child,
            ),
          },
        ),
        topNavigation: SlotLayout(
          config: {
            Breakpoints.mediumLargeAndUp: SlotLayout.from(
              key: const Key('top-app-bar'),
              builder: (context) {
                return const KeyboardAwareTopBar();
              },
            ),
          },
        ),
      ),
    );
  }
}
