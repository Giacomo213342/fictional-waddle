import 'dart:async';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../pages/account_selector/account_selector.dart';

class MatrixDeeplinkRoute extends GoRoute {
  MatrixDeeplinkRoute({super.pageBuilder, super.builder})
      : super(
          path: '/:$pathParameter',
          redirect: _matrixDeeplinkRedirect,
        );

  static const pathParameter = 'deeplink';
  static const protocolName = 'matrix';

  static Future<String> _matrixDeeplinkRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    String parameter = state.pathParameters[pathParameter]!;

    return AccountSelectorPage.makeRedirectRoute(parameter);
  }
}
