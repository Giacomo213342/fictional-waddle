import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../../widgets/matrix/scopes/matrix_identifier_scope.dart';
import 'public_room_view.dart';

class PublicRoomPage extends StatefulWidget {
  const PublicRoomPage({
    super.key,
  });

  @override
  State<PublicRoomPage> createState() => PublicRoomController();
}

class PublicRoomController extends State<PublicRoomPage> {
  PublicRoomsChunk? room;

  bool loading = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _getRoomPreview());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    context.dependOnInheritedWidgetOfExactType<MatrixIdentifierScope>();
    return PublicRoomView(controller: this);
  }

  Future<void> _getRoomPreview() async {
    final identifier = MatrixIdentifierScope.of(context).identifier;
    final via = {
      ...identifier.via,
      identifier.primaryIdentifier.domain,
      null,
    };

    final client = ClientScope.of(context).client;

    for (final server in via) {
      final response = await client.queryPublicRooms(
        server: server,
        filter: PublicRoomQueryFilter(
          genericSearchTerm: identifier.primaryIdentifier,
        ),
      );
      final room = response.chunk.firstOrNull;
      if (room == null) {
        continue;
      }

      setState(() {
        this.room = room;
      });
      break;
    }
  }

  Future<void> knockRoom() => joinRoom();

  Future<void> joinRoom() async {
    final client = ClientScope.of(context).client;
    final room = this.room;
    if (room == null) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      await client.joinRoomById(room.roomId);
      await client.waitForRoomInSync(
        room.roomId,
        join: true,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).youCannotJoinThisRoom,
            ),
          ),
        );
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> joinGuest() async {
    final room = this.room;
    if (room == null) {
      return;
    }

    setState(() {
      loading = true;
    });

    // TODO: support rendering timeline preview
    // ignore: unused_local_variable
    final events = await ClientScope.of(context)
        .client
        .getRoomEvents(room.roomId, Direction.b);

    setState(() {
      loading = false;
    });
  }
}
