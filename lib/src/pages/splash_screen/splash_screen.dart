import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
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
    await ClientManager.of(context).store.waiForInitialization;
    if (!mounted) {
      return;
    }
    if (ClientManager.of(context).store.activeClients.value.isEmpty) {
      return;
    }
    try {
      final client = ClientScope.of(context).client;
      if (client.isLogged()) {
        _roomList();
      }
      // ensure we are completely initialized
      if (client.onLoginStateChanged.value == null) {
        await client.onLoginStateChanged.stream.first.timeout(
          const Duration(seconds: 45),
        );
      }

      if (!client.isLogged() && mounted) {
        _loginView();
      }
    } on TimeoutException {
      if (mounted) {
        _fatalError();
      }
    } catch (e) {
      if (mounted) {
        _loginView();
      }
    }
  }

  void _loginView() => context.goMultiClient(HomeserverPage.routeName);

  void _roomList() => context.goMultiClient(RoomListPage.routeName);

  void _fatalError() => context.goMultiClient(FatalErrorPage.routeName);

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
