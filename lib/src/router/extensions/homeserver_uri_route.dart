import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../pages/fatal_error/fatal_error_page.dart';
import '../../pages/homeserver/homeserver.dart';
import '../../pages/login/login.dart';
import '../../pages/splash_screen/splash_screen.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import 'go_router_path_extension.dart';

typedef HomeserverUriBuilder = Widget Function(
  BuildContext context,
  GoRouterState state,
  Uri uri,
);

class HomeserverUriRoute extends GoRoute {
  HomeserverUriRoute({
    required super.path,
    super.name,
    HomeserverUriBuilder? builder,
    super.pageBuilder,
    super.parentNavigatorKey,
    super.onExit,
    super.routes = const <RouteBase>[],
  }) : super(
          redirect: _uriParseRedirect,
          builder: builder == null ? null : _roomInjectedBuilder(builder),
        );

  static Uri _decodeUriFragment(String fragment) {
    final decoded = Uri.decodeComponent(fragment);

    if (decoded.startsWith(RegExp(r'http(s)?://'))) {
      return Uri.parse(decoded);
    } else {
      return Uri.https(decoded);
    }
  }

  static FutureOr<String?> _uriParseRedirect(
    BuildContext context,
    GoRouterState state,
  ) {
    final identifier = state.clientIdentifier;
    if (identifier == null) {
      return context.clientifyLocation(SplashPage.routeName);
    }
    final client = ClientManager.of(context).getClientByIdentifier(identifier);
    if (client == null || client.isLogged()) {
      return context.clientifyLocation(SplashPage.routeName);
    }

    final hostParameter = state.pathParameters[LoginPage.pathParameter];
    if (hostParameter == null) {
      return context.clientifyLocation(HomeserverPage.routeName);
    }
    Uri? uri;
    try {
      uri = _decodeUriFragment(hostParameter);
    } catch (_) {}
    if (uri == null) {
      return context.clientifyLocation(HomeserverPage.routeName);
    }

    return null;
  }

  static GoRouterWidgetBuilder _roomInjectedBuilder(
    HomeserverUriBuilder builder,
  ) =>
      (
        BuildContext context,
        GoRouterState state,
      ) {
        final parameter = state.pathParameters[LoginPage.pathParameter];
        if (parameter == null) {
          return const FatalErrorPage();
        }
        final uri = _decodeUriFragment(parameter);

        return builder.call(context, state, uri);
      };
}
