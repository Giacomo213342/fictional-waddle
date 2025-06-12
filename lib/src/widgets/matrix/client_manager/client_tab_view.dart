import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import 'components/bottom/polycule_bottom_app_bar.dart';
import 'components/top/keyboard_aware_top_bar.dart';

class ClientTabView extends StatelessWidget {
  const ClientTabView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: AdaptiveLayout(
          transitionDuration: const Duration(milliseconds: 300),
          body: SlotLayout(
            config: {
              Breakpoints.smallAndUp: SlotLayout.from(
                key: const Key('body'),
                builder: (context) => child,
              ),
            },
          ),
          topNavigation: SlotLayout(
            config: {
              Breakpoints.mediumLargeAndUp: SlotLayout.from(
                key: const Key('top-app-bar'),
                builder: (context) {
                  return const KeyboardAwareTopBar();
                },
              ),
            },
          ),
          bottomNavigation: SlotLayout(
            config: {
              Breakpoints.small: SlotLayout.from(
                key: const Key('bottom-app-bar'),
                builder: (context) {
                  return const PolyculeBottomAppBar();
                },
              ),
              Breakpoints.medium: SlotLayout.from(
                key: const Key('bottom-app-bar'),
                builder: (context) {
                  return const PolyculeBottomAppBar();
                },
              ),
            },
          ),
        ),
      );
}
