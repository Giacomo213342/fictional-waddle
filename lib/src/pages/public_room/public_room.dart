import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/matrix/client_scope.dart';
import 'public_room_view.dart';

class PublicRoomPage extends StatefulWidget {
  const PublicRoomPage({
    super.key,
    required this.filter,
    required this.via,
    this.action,
    this.eventId,
  });

  final PublicRoomQueryFilter filter;
  final Set<String> via;
  final String? action;
  final String? eventId;

  @override
  State<PublicRoomPage> createState() => PublicRoomController();
}

class PublicRoomController extends State<PublicRoomPage> {
  PublicRoomsChunk? room;

  bool loading = false;

  String? get eventId {
    String? eventId = widget.eventId;
    if (eventId == null) {
      return null;
    }
    // yeah, a component can be twice URI encoded WTF
    return Uri.decodeComponent(eventId);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _getRoomPreview());
    super.initState();
  }

  @override
  Widget build(BuildContext context) => PublicRoomView(controller: this);

  Future<void> _getRoomPreview() async {
    final via = {
      ...widget.via,
      widget.filter.genericSearchTerm?.domain,
      null,
    };

    final client = ClientScope.of(context).client;

    for (final server in via) {
      final response = await client.queryPublicRooms(
        server: server,
        filter: widget.filter,
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
