import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/matrix/active_room_tracker.dart';
import 'components/top/keyboard_aware_top_bar.dart';

class ClientTabView extends StatelessWidget {
  const ClientTabView({super.key, required this.uri, required this.child});

  final Uri uri;
  final Widget child;

  String? get _backTarget {
    final path = uri.path;
    final room =
        RegExp(r'^(/client/\d+/rooms/[^/]+)(?:/.*)?$').firstMatch(path);
    if (room != null) {
      final roomPath = room.group(1)!;
      return path == roomPath ? null : roomPath;
    }

    final settings =
        RegExp(r'^(/client/\d+)/settings(?:/.*)?$').firstMatch(path);
    if (settings != null) {
      final settingsRoot = '${settings.group(1)!}/settings';
      return path == settingsRoot
          ? '${settings.group(1)!}/rooms'
          : settingsRoot;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final activeRoomMatch =
        RegExp(r'^/client/\d+/rooms/([^/]+)$').firstMatch(uri.path);
    ActiveRoomTracker.roomId = activeRoomMatch == null
        ? null
        : Uri.decodeComponent(activeRoomMatch.group(1)!);

    return BackButtonListener(
      onBackButtonPressed: () async {
        final target = _backTarget;
        if (target == null) {
          return false;
        }
        context.go(target);
        return true;
      },
      child: Scaffold(
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
      ),
    );
  }
}
