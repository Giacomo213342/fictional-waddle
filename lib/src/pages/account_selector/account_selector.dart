import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/matrix/client_manager/client_manager.dart';
import '../room/room.dart';
import '../user_page/user_page.dart';
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
  Widget build(BuildContext context) => AccountSelectorView(controller: this);

  Future<void> selectAccount(int identifier) async {
    // handle [matrix] calls
    final matrixCallUri = Uri.tryParse(widget.redirect);
    final matrixCallLink = matrixCallUri?.queryParameters['url'];

    if (matrixCallUri?.scheme == 'io.element.call' && matrixCallLink != null) {
      final uri = Uri.tryParse(Uri.decodeComponent(matrixCallLink));
      if (uri != null) {
        context.pushReplacement('/client/$identifier');
        // redirect to the web browser
        launchUrl(uri);
        return;
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
      '/client/$identifier/$path',
    );
  }

  void _matrixRedirect(
    int identifier,
    MatrixIdentifierStringExtensionResults matrixLink,
  ) {
    final mxid = matrixLink.primaryIdentifier;

    final prefix = mxid.sigil;

    final client = ClientManager.of(context).getClientByIdentifier(identifier);
    if (client == null) {
      Navigator.of(context).pop();
      return;
    }
    Room? room;

    if (prefix == '@') {
      final directChat = client.getDirectChatFromUserId(mxid);

      // if we don't know the direct chat, show the user page
      if (directChat == null) {
        context.pushReplacement(
          '/client/$identifier${UserPage.makeRouteName(mxid)}',
        );
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
