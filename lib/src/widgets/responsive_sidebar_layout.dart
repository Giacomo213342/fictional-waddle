import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import 'placeholder.dart';

class ResponsiveSidebarLayout extends StatelessWidget {
  const ResponsiveSidebarLayout({
    super.key,
    required this.uri,
    required this.main,
    required this.sidebar,
    this.placeholder = const PolyculePlaceholder(),
  });

  final Uri? uri;

  final Widget main;

  final Widget? sidebar;

  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final sidebar = this.sidebar;
    bool showSidebar;
    final segments =
        uri?.path.replaceFirst(RegExp(r'/client/\d+'), '').split('/');
    segments?.removeWhere((element) => element.isEmpty);

    if (segments == null) {
      showSidebar = false;
    } else if (segments.length < 3) {
      showSidebar = false;
    } else if (sidebar == null) {
      showSidebar = false;
    } else {
      showSidebar = true;
    }
    final layout = AdaptiveLayout(
      // SlotLayout otherwise cross-fades builder replacements. While changing
      // rooms that keeps the previous timeline visible underneath the new one.
      transitionDuration: Duration.zero,
      body: SlotLayout(
        config: {
          Breakpoints.smallAndUp: SlotLayout.from(
            key: const Key('main-small'),
            builder: (context) => showSidebar ? sidebar ?? main : main,
          ),
          Breakpoints.largeAndUp: SlotLayout.from(
            key: const Key('main'),
            builder: (context) => main,
          ),
        },
      ),
      secondaryBody: sidebar == null || !showSidebar
          ? null
          : SlotLayout(
              config: {
                Breakpoints.largeAndUp: SlotLayout.from(
                  key: const Key('secondary'),
                  builder: (context) => sidebar,
                ),
              },
            ),
      bodyRatio: .65,
    );

    if (sidebar == null || showSidebar) {
      return layout;
    }

    // A ShellRoute's child is its active Navigator. It must remain mounted
    // even when the compact layout displays [main] instead, otherwise
    // GoRouter's system-back traversal reaches an active ShellRouteMatch whose
    // navigatorKey.currentState is null.
    return Stack(
      fit: StackFit.expand,
      children: [
        layout,
        Positioned.fill(
          child: Offstage(
            offstage: true,
            child: TickerMode(enabled: false, child: sidebar),
          ),
        ),
      ],
    );
  }
}
