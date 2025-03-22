import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

class SessionScope extends InheritedWidget {
  const SessionScope({
    super.key,
    required this.session,
    required super.child,
  });

  static SessionScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<SessionScope>()!;
    return scope;
  }

  final DeviceKeys session;

  @override
  bool updateShouldNotify(covariant SessionScope oldWidget) =>
      session != oldWidget.session ||
      session.verified != oldWidget.session.verified ||
      session.blocked != oldWidget.session.blocked;
}
