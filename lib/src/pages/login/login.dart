import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../utils/matrix/matrix_state.dart';
import '../homeserver/homeserver.dart';
import 'login_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.homeserver});

  static const routeName = '${HomeserverPage.routeName}/:$pathParameter';
  static const pathParameter = 'server';

  static String makeRouteName(Uri homeserver) {
    if (homeserver.isScheme('https')) {
      if (homeserver.hasPort) {
        return '${HomeserverPage.routeName}/${Uri.encodeComponent('${homeserver.host}:${homeserver.port}')}';
      }
      return '${HomeserverPage.routeName}/${homeserver.host}';
    } else {
      return '${HomeserverPage.routeName}/${Uri.encodeComponent(homeserver.toString())}';
    }
  }

  final Uri homeserver;

  @override
  State<LoginPage> createState() => LoginController();
}

class LoginController extends MatrixState<LoginPage> {
  Uri get homeserver => widget.homeserver;

  Future<HomeserverSummary?>? homeserverCheck;

  @override
  void initState() {
    homeserverCheck =
        Future<HomeserverSummary?>.value(client.checkHomeserver(homeserver))
          ..onError(_popHomeserverError);
    super.initState();
  }

  @override
  Widget build(BuildContext context) => LoginView(this);

  FutureOr<HomeserverSummary?> _popHomeserverError(
    Object error,
    StackTrace stackTrace,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context)!
              .errorConnectingToHomeserver(homeserver.toString()),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.canPop()) {
        context.pop();
      }
      context.go(HomeserverPage.routeName);
    });
    return null;
  }
}
