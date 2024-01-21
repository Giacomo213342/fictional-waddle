import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'components/room_list.dart';
import 'components/sync_update_status_row.dart';
import 'room_list.dart';

class RoomListView extends StatelessWidget {
  const RoomListView(this.controller, {super.key});

  final RoomListController controller;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SyncUpdate>(
      stream: controller.client.onSync.stream,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: FutureBuilder<String?>(
              future: Future.value(),
              builder: (context, snapshot) {
                return Text(
                  AppLocalizations.of(context)
                      .hajUser(controller.client.userID),
                );
              },
            ),
          ),
          body: Column(
            children: [
              Expanded(
                child: RoomList(controller),
              ),
              SyncUpdateStatusRow(
                syncUpdate: snapshot.data,
                timestamp: DateTime.now(),
              ),
            ],
          ),
        );
      },
    );
  }
}
