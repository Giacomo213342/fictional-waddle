import 'package:flutter/material.dart';

import 'package:matrix/encryption.dart';

class SasScope extends InheritedWidget {
  const SasScope({super.key, required this.verification, required super.child});

  factory SasScope.of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SasScope>()!;

  final KeyVerification verification;

  @override
  bool updateShouldNotify(covariant SasScope oldWidget) =>
      verification != oldWidget.verification;
}
