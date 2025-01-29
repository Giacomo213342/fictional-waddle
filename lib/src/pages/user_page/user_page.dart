import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/client_scope.dart';
import '../../widgets/matrix/key_verification/key_verification_request_widget.dart';
import '../room/room.dart';
import 'user_view.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key, required this.mxid});

  final String mxid;

  static String makeRouteName([String? mxid]) =>
      '/user/${mxid != null ? Uri.encodeComponent(mxid) : r':' + pathParameter}';
  static const pathParameter = 'mxid';

  @override
  State<UserPage> createState() => UserController();
}

class UserController extends State<UserPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) => UserView(controller: this);

  Future<void> startDirectChat() async {
    setState(() {
      loading = true;
    });
    final roomId = await ClientScope.of(context).client.startDirectChat(
          widget.mxid,
          enableEncryption: true,
        );
    if (!mounted) {
      return;
    }
    context.goMultiClient(RoomPage.makeRouteName(roomId));
    setState(() {
      loading = false;
    });
  }

  Future<void> toggleIgnore() async {
    final client = ClientScope.of(context).client;
    setState(() {
      loading = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).ignoreToggleWaiting)),
    );
    if (client.ignoredUsers.contains(widget.mxid)) {
      await client.unignoreUser(widget.mxid);
    } else {
      await client.ignoreUser(widget.mxid);
    }
    await client.oneShotSync();
    if (!mounted) {
      return;
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> startVerification() async {
    final client = ClientScope.of(context).client;
    final encryption = client.encryption;
    final roomId = client.getDirectChatFromUserId(widget.mxid);
    if (roomId == null || encryption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).keyVerificationErrorGeneric),
        ),
      );
      return;
    }
    final room = client.getRoomById(roomId);
    if (room == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).keyVerificationErrorGeneric),
        ),
      );
      return;
    }

    final request = KeyVerification(
      encryption: encryption,
      userId: widget.mxid,
      room: room,
    );

    encryption.keyVerificationManager.addRequest(request);

    setState(() {
      loading = true;
    });

    KeyVerificationRequestWidget.showDialog(
      request,
      context: context,
      client: client,
    );
    await request.start();

    setState(() {
      loading = false;
    });
  }
}
