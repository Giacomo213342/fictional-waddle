import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class ClientScope extends InheritedWidget {
  const ClientScope({
    super.key,
    required this.client,
    required super.child,
  });

  static ClientScope of(BuildContext context) {
    final ClientScope scope =
        context.dependOnInheritedWidgetOfExactType<ClientScope>()!;
    return scope;
  }

  final Client client;

  @override
  bool updateShouldNotify(covariant ClientScope oldWidget) =>
      client != oldWidget.client;
}
