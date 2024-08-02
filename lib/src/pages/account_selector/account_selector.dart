import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/sharing_intent_banner/sharing_intent_banner.dart';
import '../room/room.dart';
import 'account_selector_view.dart';

class AccountSelectorPage extends StatefulWidget {
  const AccountSelectorPage({super.key, required this.redirect});

  static const routeName = '/accounts';

  final MatrixIdentifierStringExtensionResults? redirect;

  @override
  State<AccountSelectorPage> createState() => AccountSelectorController();

  static String makeRedirectRoute(String destination) {
    return '$routeName?redirect=${Uri.encodeComponent(destination)}';
  }
}

class AccountSelectorController extends State<AccountSelectorPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSharingData());

    super.initState();
  }

  @override
  Widget build(BuildContext context) => AccountSelectorView(controller: this);

  Future<void> selectAccount(int identifier) async {
    final mxid = widget.redirect?.primaryIdentifier;
    if (mxid == null) {
      context.pushReplacement(
        '/client/$identifier',
      );
      return;
    }

    final prefix = mxid.substring(0, 1);

    if (prefix == '!') {
      context.pushReplacement(
        '/client/$identifier${RoomPage.makeRouteName(mxid)}',
      );
      return;
    }

    final client = ClientManager.getClientByIdentifier(identifier);
    if (client == null) {
      context.pop();
      return;
    }

    if (prefix == '#') {
      String? roomId;
      try {
        roomId = client.getRoomByAlias(mxid)?.id ??
            (await client.getRoomIdByAlias(mxid)).roomId;
      } catch (e) {
        if (mounted) {
          context.pop();
        }
        return;
      }
      if (!mounted) {
        return;
      }
      if (roomId == null) {
        context.pushReplacement(
          '/client/$identifier${RoomPage.makeRouteName(mxid)}',
        );
        return;
      }
      context.pushReplacement(
        '/client/$identifier${RoomPage.makeRouteName(roomId)}',
      );
      return;
    }

    if (prefix == '@') {
      final room = client.getDirectChatFromUserId(mxid);
      if (room == null) {
        context.pushReplacement('/client/$identifier/user/$mxid');
      } else {
        context.pushReplacement(
          '/client/$identifier${RoomPage.makeRouteName(room)}',
        );
      }
      return;
    }
  }

  void _checkSharingData() {
    if (ClientManager.sharedFilesListener.value != null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        SharingIntentBanner.files(),
      );
    } else if (ClientManager.sharedTextListener.value != null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        SharingIntentBanner.text(),
      );
    }
  }
}
