import 'package:flutter/material.dart';

import 'package:animations/animations.dart';

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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          bool reverse = false;
          bool showSidebar;
          final segments =
              uri?.path.replaceFirst(RegExp(r'/client/\d+'), '').split('/');
          segments?.removeWhere((element) => element.isEmpty);

          if (segments == null) {
            showSidebar = false;
          } else if (segments.length < 3) {
            showSidebar = false;
            reverse = true;
          } else if (sidebar == null) {
            showSidebar = false;
          } else {
            showSidebar = true;
          }

          if (constraints.maxWidth > 764) {
            return Scaffold(
              key: const ValueKey(ScaffoldMessenger),
              body: Row(
                children: [
                  Expanded(
                    child: OverflowBox(
                      maxWidth:
                          constraints.maxWidth - (showSidebar ? 256 + 192 : 0),
                      child: main,
                    ),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 150),
                    child: SizedBox(
                      width: showSidebar ? 256 + 192 : 0,
                      child: _buildAnimation(context, sidebar ?? placeholder),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return _buildAnimation(
              context,
              showSidebar ? sidebar ?? main : main,
              reverse,
            );
          }
        },
      );

  Widget _buildAnimation(
    BuildContext context,
    Widget child, [
    bool reverse = false,
  ]) {
    return PageTransitionSwitcher(
      reverse: reverse,
      transitionBuilder: (
        Widget child,
        Animation<double> primaryAnimation,
        Animation<double> secondaryAnimation,
      ) {
        return SharedAxisTransition(
          animation: primaryAnimation,
          secondaryAnimation: secondaryAnimation,
          transitionType: SharedAxisTransitionType.scaled,
          fillColor: Theme.of(context).colorScheme.surface,
          child: child,
        );
      },
      child: Container(
        key: ValueKey(uri?.toString()),
        child: child,
      ),
    );
  }
}
