import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:matrix/matrix.dart';

class MatrixIdentifierScope extends InheritedWidget {
  const MatrixIdentifierScope({
    super.key,
    required super.child,
    required this.identifier,
  });

  factory MatrixIdentifierScope.of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MatrixIdentifierScope>()!;

  factory MatrixIdentifierScope.fromGoRouterState({
    required GoRouterState state,
    required Widget child,
  }) {
    final primaryIdentifier = Uri.decodeComponent(
      state.pathParameters[pathParameter]!,
    );
    final action = state.uri.queryParameters['action'];
    final via = state.uri.queryParametersAll['via']?.toSet() ?? {};
    return MatrixIdentifierScope(
      identifier: MatrixIdentifierStringExtensionResults(
        primaryIdentifier: primaryIdentifier,
        action: action,
        via: via,
      ),
      child: child,
    );
  }

  static MatrixIdentifierScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MatrixIdentifierScope>();

  static const pathParameter = 'mxid';

  final MatrixIdentifierStringExtensionResults identifier;

  @override
  bool updateShouldNotify(covariant MatrixIdentifierScope oldWidget) =>
      identifier != oldWidget.identifier;
}
