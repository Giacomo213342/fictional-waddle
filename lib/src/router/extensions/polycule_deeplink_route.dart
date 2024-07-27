import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class PolyculeDeeplinkRoute extends GoRoute {
  PolyculeDeeplinkRoute({super.pageBuilder, super.builder})
      : super(
          path: '$routeName/:$pathParameter',
          redirect: _matrixDeeplinkRedirect,
        );

  static const routeName = '/polycule';
  static const pathParameter = 'deeplink';
  static const protocolName = 'polycule';

  static Future<String> _matrixDeeplinkRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    String parameter = state.pathParameters[pathParameter]!;
    String decodedUri = Uri.decodeComponent(parameter);
    Logs().d('Received polycule deep link : $decodedUri');

    return '/';
  }
}
