import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:matrix/matrix.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_scope.dart';
import '../fatal_error/fatal_error_page.dart';
import '../homeserver/homeserver.dart';
import '../room_list/room_list.dart';
import 'splash_screen_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const routeName = '/';

  @override
  State<SplashPage> createState() => SplashController();
}

class SplashController extends State<SplashPage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkLoginState());
    super.initState();
  }

  Future<void> _checkLoginState() async {
    await ClientManager.waiForInitialization;
    if (!mounted || ClientManager.activeClients.isEmpty) {
      return;
    }
    try {
      final client = ClientScope.of(context).client;
      if (client.isLogged()) {
        _roomList();
      }
      final loginState = client.onLoginStateChanged.value ??
          await client.onLoginStateChanged.stream.first.timeout(
            const Duration(seconds: 45),
          );

      if (loginState != LoginState.loggedIn) {
        _loginView();
      }
    } on TimeoutException {
      _fatalError();
    } catch (e) {
      _loginView();
    }
  }

  void _loginView() => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            context.goMultiClient(HomeserverPage.routeName);
          }
        },
      );

  void _roomList() => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            context.goMultiClient(RoomListPage.routeName);
          }
        },
      );

  void _fatalError() => WidgetsBinding.instance.addPostFrameCallback(
        (_) {
          if (mounted) {
            context.goMultiClient(FatalErrorPage.routeName);
          }
        },
      );

  @override
  Widget build(BuildContext context) => SplashPageView(this);

  @override
  void didUpdateWidget(covariant SplashPage oldWidget) {
    if (oldWidget.key != widget.key) {
      _checkLoginState();
    }
    super.didUpdateWidget(oldWidget);
  }
}
