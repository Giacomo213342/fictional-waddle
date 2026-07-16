import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';
import 'package:go_router/go_router.dart';

import '../../../pages/room_list/room_list_position_tracker.dart';
import '../../../utils/matrix/active_room_tracker.dart';
import '../scopes/client_scope.dart';
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

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (activeRoomMatch == null) return false;

        // Dialogs, media viewers and bottom sheets live on the root navigator.
        // They must consume Android back before the room route does.
        if (Navigator.of(context, rootNavigator: true).canPop()) return false;

        final roomId = Uri.decodeComponent(activeRoomMatch.group(1)!);
        final room = ClientScope.of(context).client.getRoomById(roomId);
        if (room != null) {
          RoomListPositionTracker.prepareReturn(room);
        }
        if (uri.fragment.isNotEmpty) {
          context.go(uri.replace(fragment: '').toString());
        } else {
          final roomPath = uri.path;
          context.go(
            uri
                .replace(
                  path: roomPath.substring(0, roomPath.lastIndexOf('/')),
                  fragment: '',
                )
                .toString(),
          );
        }
        return true;
      },
      child: Scaffold(
        body: AdaptiveLayout(
          transitionDuration: Duration.zero,
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
