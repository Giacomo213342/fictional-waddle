import 'package:flutter/material.dart';

import 'top/keyboard_aware_top_bar.dart';

class TopTabBarView extends StatelessWidget {
  const TopTabBarView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          const KeyboardAwareTopBar(),
          Expanded(child: child),
        ],
      ),
    );
  }
}
