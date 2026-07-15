import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../widgets/matrix/scopes/client_scope.dart';
import 'components/fade_in_room_list.dart';
import 'components/initial_sync_tile.dart';
import 'components/room_search_bar.dart';
import 'components/sync_update_status_row.dart';
import 'room_list.dart';

class RoomListView extends StatelessWidget {
  const RoomListView(this.controller, {super.key});

  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: <ShortcutActivator, VoidCallback>{
        const SingleActivator(LogicalKeyboardKey.slash): controller.command,
        const SingleActivator(LogicalKeyboardKey.semicolon): controller.search,
        const CharacterActivator(':'): controller.search,
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: const RoomSearchBar(),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: 8),
          child: Column(
            children: [
              const InitialSyncTile(),
              const Expanded(
                child: FadeInRoomList(),
              ),
              StreamBuilder<SyncUpdate>(
                stream: ClientScope.of(context).client.onSync.stream,
                builder: (context, snapshot) {
                  return SyncUpdateStatusRow(
                    syncUpdate: snapshot.data,
                    timestamp: DateTime.now(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
