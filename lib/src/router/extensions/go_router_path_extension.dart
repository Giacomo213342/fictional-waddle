import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

import '../../pages/application_splash_screen/application_splash_screen.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_manager/client_store.dart';
import '../../widgets/matrix/scopes/client_scope.dart';

const pathParameter = 'client';

extension GoRouterPathExtension on String {
  String asGoRouterPath() => ':$this';
}

RegExp get _clientRegex => RegExp(r'^/client/(\d+)/?');

extension GoRouterMultiClient on BuildContext {
  void goMultiClient(String location, {Object? extra}) {
    location = clientifyLocation(location);
    return GoRouter.of(this).go(location, extra: extra);
  }

  Future<T?> pushMultiClient<T>(String location, {Object? extra}) {
    location = clientifyLocation(location);
    return GoRouter.of(this).push<T>(location, extra: extra);
  }

  String clientifyLocation(String location) {
    if (!_clientRegex.hasMatch(location)) {
      Client? client;
      try {
        client = ClientScope.of(this).client;
      } catch (_) {}

      if (client == null) {
        if (ClientManager.of(this).store.activeClients.value.isEmpty) {
          return ApplicationSplashScreen.routeName +
              r'?from=' +
              Uri.encodeComponent(location);
        }
        final client = ClientManager.of(this).store.activeClients.value.first;
        location = '/client/${client.clientName.clientIdentifier}'
            '?from=${Uri.encodeComponent(location)}';
      } else {
        location = '/client/${client.clientName.clientIdentifier}$location';
      }
    }
    return location;
  }
}

extension ClientIndentifier on GoRouterState {
  int? get clientIdentifier {
    final path = this.path;
    if (path == null) {
      return null;
    }
    final match = _clientRegex.firstMatch(path);
    final parameter = match?.group(1);
    if (parameter == null) {
      return null;
    }
    return int.tryParse(parameter);
  }
}
