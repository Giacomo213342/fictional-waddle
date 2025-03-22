import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/sas_verification/sas_verification_request_widget.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import '../../widgets/matrix/scopes/matrix_identifier_scope.dart';
import '../room/room.dart';
import 'user_view.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  static String makeRouteName([String? mxid, String? secondary]) =>
      '/user/${mxid != null ? Uri.encodeComponent(mxid) : r':' + MatrixIdentifierScope.pathParameter}${secondary == null ? '' : '/$secondary'}';

  static String makeRoomRouteName(String roomId, String mxid) =>
      '${RoomPage.makeRouteName(roomId)}/user/${Uri.encodeComponent(mxid)}';
  static final roomPath =
      '${RoomPage.pathParameter.asGoRouterPath()}/user/:${MatrixIdentifierScope.pathParameter}';

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
    final mxid = MatrixIdentifierScope.of(context).identifier.primaryIdentifier;
    final roomId = await ClientScope.of(context).client.startDirectChat(
          mxid,
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
    final mxid = MatrixIdentifierScope.of(context).identifier.primaryIdentifier;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).ignoreToggleWaiting)),
    );
    if (client.ignoredUsers.contains(mxid)) {
      await client.unignoreUser(mxid);
    } else {
      await client.ignoreUser(mxid);
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
    final mxid = MatrixIdentifierScope.of(context).identifier.primaryIdentifier;
    final roomId = client.getDirectChatFromUserId(mxid);
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
      userId: mxid,
      room: room,
    );

    encryption.keyVerificationManager.addRequest(request);

    setState(() {
      loading = true;
    });

    SasVerificationRequestWidget.showDialog(
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
