import 'package:flutter/widgets.dart';

import 'package:go_router/go_router.dart';

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
          location = '/client/1?from=${Uri.encodeComponent(location)}';
        } else {
          location = '/client/$client$location';
        }
      }
    }
    return location;
  }
}
