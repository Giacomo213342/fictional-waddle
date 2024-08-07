import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/intent_manager.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/sharing_intent_banner/sharing_intent_banner.dart';
import '../room/room.dart';
import 'account_selector_view.dart';

class AccountSelectorPage extends StatefulWidget {
  const AccountSelectorPage({super.key, required this.redirect});

  static const routeName = '/accounts';

  final String redirect;

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
    // handle [matrix] calls
    final matrixCallUri = Uri.tryParse(widget.redirect);
    final matrixCallLink = matrixCallUri?.queryParameters['url'];

    if (matrixCallUri?.scheme == 'io.element.call' && matrixCallLink != null) {
      final uri = Uri.tryParse(Uri.decodeComponent(matrixCallLink));
      if (uri != null) {
        context.pushReplacement(
          '/client/$identifier',
        );
        // redirect to the web browser
        launchUrl(uri);
      }
    }

    final matrixLink = widget.redirect.parseIdentifierIntoParts();

    if (matrixLink != null) {
      return _matrixRedirect(identifier, matrixLink);
    }
    String path = widget.redirect;
    if (path.startsWith('/')) {
      path = path.replaceFirst('/', '');
    }
    context.pushReplacement(
      '/client/$identifier/$path}',
    );
  }

  void _checkSharingData() {
    // funny bug : any deeplink will meanwhile be interpreted as shared text
    // easy workaround : if the shared text is equal to the redirect, we know
    // it was the same data processed
    if (IntentManager.sharedTextListener.value == widget.redirect) {
      IntentManager.claimShareIntent();
      return;
    }
    if (IntentManager.sharedFilesListener.value != null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        SharingIntentBanner.files(),
      );
    } else if (IntentManager.sharedTextListener.value != null) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        SharingIntentBanner.text(),
      );
    }
  }

  void _matrixRedirect(
    int identifier,
    MatrixIdentifierStringExtensionResults matrixLink,
  ) {
    final mxid = matrixLink.primaryIdentifier;

    final prefix = mxid.sigil;

    final client = ClientManager.getClientByIdentifier(identifier);
    if (client == null) {
      Navigator.of(context).pop();
      return;
    }
    Room? room;

    if (prefix == '@') {
      final directChat = client.getDirectChatFromUserId(mxid);

      // if we don't know the direct chat, show the user page
      if (directChat == null) {
        context.pushReplacement('/client/$identifier/user/$mxid');
        return;
      }
      // otherwise set the room and let the room handler do the rest
      room = client.getRoomById(directChat);
    }

    if (room != null || prefix == '#' || prefix == '!') {
      room ??= client.getRoomByAlias(mxid);
      room ??= client.getRoomById(mxid);

      final query = matrixLink.queryString;
      final event = matrixLink.secondaryIdentifier;

      String path = '/client/$identifier';

      // if known room, deep link the real room id
      if (room is Room) {
        path += RoomPage.makeRouteName(room.id);
      } else {
        // otherwise use the alias
        path += RoomPage.makeRouteName(mxid);
        // add via and action for unknown rooms
        if (query != null) {
          path += '?${matrixLink.queryString}';
        }
      }
      if (event != null) {
        path += '#${Uri.encodeComponent(event)}';
      }

      context.pushReplacement(path);
      return;
    }
  }
}
