import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';
import 'package:olm/olm.dart' as olm;

import '../../../pages/account_selector/account_selector.dart';
import '../../../pages/account_settings/account_settings.dart';
import '../../../pages/fatal_error/fatal_error_page.dart';
import '../../../pages/homeserver/homeserver.dart';
import '../../../pages/room_list/room_list.dart';
import '../../../pages/ssss_bootstrap/ssss_bootstrap.dart';
import '../../../router/extensions/go_router_path_extension.dart';
import '../scopes/client_scope.dart';
import 'client_store.dart';
import 'components/bottom_tab_bar_view.dart';
import 'components/top_tab_bar_view.dart';

class ClientTabView extends StatefulWidget {
  const ClientTabView({super.key, required this.child});

  final Widget child;

  @override
  State<ClientTabView> createState() => _ClientTabViewState();
}

class _ClientTabViewState extends State<ClientTabView> {
  static String? _olmVersion;

  StreamSubscription<LoginState>? _loginStateSubscription;

  @override
  void didChangeDependencies() {
    _loginStateSubscription?.cancel();
    _loginStateSubscription = _subscribeListener(context);

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _loginStateSubscription?.cancel();
    super.dispose();
  }

  StreamSubscription<LoginState> _subscribeListener(BuildContext context) =>
      ClientScope.of(context)
          .client
          .onLoginStateChanged
          .stream
          .listen(_handleLoginState);

  @override
  Widget build(BuildContext context) {
    _loginStateSubscription ??= _subscribeListener(context);
    return LayoutBuilder(
      builder: (context, constraints) =>
          constraints.maxWidth > 764 || (!kIsWeb && Platform.isIOS)
              ? TopTabBarView(child: widget.child)
              : BottomTabBarView(child: widget.child),
    );
  }

  void _handleLoginState(LoginState state) {
    final client = ClientScope.of(context).client;
    switch (state) {
      case LoginState.softLoggedOut:
      // we let the SDK handle soft log out
      case LoginState.loggedIn:
        // under no case start the app if encryption not supported
        // This should prevent from CI accidentally forgetting to bundle OLM
        if (_olmVersion == null) {
          try {
            _olmVersion = olm.get_library_version().join('.');
            Logs().d('Running with OLM version $_olmVersion');
          } on ArgumentError catch (e, s) {
            Logs().wtf('Unable to load OLM.', e, s);
            client.dispose();

            context.goMultiClient(FatalErrorPage.routeName, extra: e);
            rethrow;
          }
        }

        final path = GoRouterState.of(context).uri.path;

        final isAccountSelector = path.startsWith(
          AccountSelectorPage.routeName,
        );
        // TODO: remove awful match
        final isLoggedInRoute = path.startsWith(
          RegExp('/client/${client.clientName.clientIdentifier}'
              '(${RoomListPage.routeName}|${SsssBootstrapPage.routeName}|'
              '/user|${AccountSettings.routeName})'),
        );
        if (!isAccountSelector && !isLoggedInRoute) {
          context.goMultiClient(RoomListPage.routeName);
        }

        break;
      case LoginState.loggedOut:
        final path = GoRouterState.of(context).uri.path;
        if (path.startsWith('/client/${client.clientName.clientIdentifier}') &&
            !path.startsWith(
              AccountSelectorPage.routeName,
            )) {
          context.goMultiClient(HomeserverPage.routeName);
        }

        break;
    }
  }
}
