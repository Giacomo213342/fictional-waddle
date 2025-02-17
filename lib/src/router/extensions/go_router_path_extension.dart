import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

import '../../pages/splash_screen/splash_screen.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/client_manager/client_store.dart';

const pathParameter = 'client';

extension GoRouterPathExtension on String {
  String asGoRouterPath() => ':$this';

  String asMultiClientRoute() =>
      '/client/:$pathParameter$this'.replaceFirst(RegExp(r'/$'), '');
}

extension GoRouterMultiClient on BuildContext {
  RegExp get _clientRegex => RegExp(r'^/client/(\d+)/?');

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
      final route = ModalRoute.of(this);
      final arguments = route?.settings.arguments;

      if (arguments is Map<String, String>) {
        final client = arguments['client'];
        if (client == null) {
          if (ClientManager.of(this).store.activeClients.value.isEmpty) {
            return SplashPage.routeName;
          }
          final client = ClientManager.of(this).store.activeClients.value.first;
          location = '/client/${client.clientName.clientIdentifier}'
              '?from=${Uri.encodeComponent(location)}';
        } else {
          location = '/client/$client$location';
        }
      }
    }
    return location;
  }
}

extension ClientIndentifier on GoRouterState {
  int? get clientIdentifier {
    final parameter = pathParameters['client'];
    if (parameter == null) {
      return null;
    }
    return int.tryParse(parameter);
  }
}
