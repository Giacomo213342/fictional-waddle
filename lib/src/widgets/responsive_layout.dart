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
    segments?.removeWhere((element) => element.isEmpty);
    final showSecondary =
        segments != null && segments.length >= 2 && secondary != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < Breakpoints.mediumLargeAndUp.beginWidth!) {
          return ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  ignoring: showSecondary,
                  child: AnimatedSlide(
                    offset:
                        showSecondary ? const Offset(-0.08, 0) : Offset.zero,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    child: main,
                  ),
                ),
                if (secondary != null)
                  IgnorePointer(
                    ignoring: !showSecondary,
                    child: AnimatedSlide(
                      offset: showSecondary ? Offset.zero : const Offset(1, 0),
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOutCubic,
                      child: secondary,
                    ),
                  ),
              ],
            ),
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
