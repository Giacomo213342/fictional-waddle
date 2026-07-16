import 'package:flutter/material.dart';

import 'package:flutter_adaptive_scaffold/flutter_adaptive_scaffold.dart';

import 'placeholder.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.uri,
    required this.main,
    required this.secondary,
    this.placeholder = const PolyculePlaceholder(),
  });

  final Uri? uri;

  final Widget main;

  final Widget? secondary;

  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final segments =
        uri?.path.replaceFirst(RegExp(r'/client/\d+'), '').split('/');
    var showSecondary = false;
    if (segments != null) {
      segments.removeWhere((element) => element.isEmpty);
      showSecondary = segments.length >= 2 && secondary != null;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mediumLargeAndUp.beginWidth!) {
          return Stack(
            fit: StackFit.expand,
            children: [
              main,
              IgnorePointer(
                ignoring: !showSecondary,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  reverseDuration: const Duration(milliseconds: 180),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.08, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: showSecondary
                      ? KeyedSubtree(
                          key: ValueKey('secondary:${uri?.path}'),
                          child: secondary!,
                        )
                      : const SizedBox.shrink(key: ValueKey('main')),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              SizedBox(
                width: 512,
                child: main,
              ),
              Expanded(child: secondary ?? placeholder),
            ],
          );
        }
      },
    );
  }
}
