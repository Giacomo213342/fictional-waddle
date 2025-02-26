import 'package:flutter/material.dart';

import '../../../polycule_overflow_bar.dart';

class SasVerificationBottomBar extends StatelessWidget {
  const SasVerificationBottomBar({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PolyculeOverflowBar(
      alignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }
}
