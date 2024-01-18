import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../utils/matrix/matrix_state.dart';
import '../homeserver/homeserver.dart';
import '../room_list/room_list.dart';
import 'splash_screen_view.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  static const routeName = '/';

  @override
  State<SplashPage> createState() => SplashController();
}

class SplashController extends MatrixState<SplashPage> {
  @override
  void initState() {
    _checkLoginState();
    super.initState();
  }

  Future<void> _checkLoginState() async {
    if (!client.isLogged()) {
      await client.init(
        waitForFirstSync: false,
      );
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(HomeserverPage.routeName),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => context.go(RoomListPage.routeName),
      );
    }
  }

  @override
  Widget build(BuildContext context) => SplashPageView(this);
}
