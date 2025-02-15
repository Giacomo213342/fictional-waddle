import 'package:flutter/material.dart';

import '../homeserver/homeserver.dart';
import 'login_view.dart';

class LoginPage extends StatelessWidget {
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
  Widget build(BuildContext context) => LoginScope(
        homeserver: homeserver,
        child: const LoginView(),
      );
}

class LoginScope extends InheritedWidget {
  const LoginScope({
    super.key,
    required this.homeserver,
    required super.child,
  });

  static LoginScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LoginScope>()!;

  final Uri homeserver;

  @override
  bool updateShouldNotify(covariant LoginScope oldWidget) =>
      homeserver != oldWidget.homeserver;
}
