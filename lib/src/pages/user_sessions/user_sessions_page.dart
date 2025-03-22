import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../../widgets/matrix/scopes/matrix_identifier_scope.dart';
import '../../widgets/matrix/scopes/room_scope.dart';
import '../../widgets/matrix/scopes/session_scope.dart';
import '../../widgets/matrix/update_user_device_keys_button.dart';
import '../room/room.dart';
import 'components/session_tile.dart';
import 'components/verify_user_button.dart';

class UserSessionsPage extends StatelessWidget {
  const UserSessionsPage({super.key});

  static String makeRouteName(String roomId, String mxid) =>
      '${RoomPage.makeRouteName(roomId)}/user/${Uri.encodeComponent(mxid)}/sessions';
  static final path =
      '${RoomPage.pathParameter.asGoRouterPath()}/user/:${MatrixIdentifierScope.pathParameter}/sessions';

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final room = RoomScope.of(context).room;
    final mxid = MatrixIdentifierScope.of(context).identifier.primaryIdentifier;

    return Scaffold(
      appBar: AppBar(
        leading: const CloseButton(),
        title: RoomBuilder(
          builder: (context, snapshot) => FutureBuilder(
            future: (snapshot.data ?? room).requestUser(mxid),
            builder: (context, snapshot) =>
                Text(snapshot.data?.displayName ?? mxid),
          ),
        ),
        actions: [
          const UpdateUserDeviceKeysButton(),
          const VerifyUserButton(),
        ],
      ),
      body: StreamBuilder<DeviceKeysList?>(
        initialData: client.userDeviceKeys[mxid],
        stream: client.onSync.stream
            .where((update) => update.deviceLists != null)
            .map((_) => client.userDeviceKeys[mxid]),
        builder: (context, s) {
          final keys = s.data?.deviceKeys.values.toList();
          if (keys == null) {
            return const Center(
              child: AsciiProgressIndicator(),
            );
          }
          keys.sort((a, b) {
            final aLastSeen = a.lastActive;
            final bLastSeen = b.lastActive;
            return bLastSeen.compareTo(aLastSeen);
          });
          return ListView.builder(
            itemCount: keys.length,
            itemBuilder: (context, index) => SessionScope(
              session: keys[index],
              child: const SessionTile(),
            ),
          );
        },
      ),
    );
  }
}
