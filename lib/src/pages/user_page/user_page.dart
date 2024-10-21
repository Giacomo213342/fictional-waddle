import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../utils/matrix/matrix_state.dart';
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

class UserController extends MatrixState<UserPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) => UserView(controller: this);

  Future<void> startDirectChat() async {
    setState(() {
      loading = true;
    });
    final roomId = await client.startDirectChat(
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
}
