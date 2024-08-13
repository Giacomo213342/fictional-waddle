import 'package:flutter/material.dart';

import 'package:animations/animations.dart';

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
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 764) {
            return Scaffold(
              key: const ValueKey(ScaffoldMessenger),
              body: Row(
                children: [
                  SizedBox(
                    width: 256 + 192,
                    child: main,
                  ),
                  Expanded(
                    child: _buildAnimation(context, secondary ?? placeholder),
                  ),
                ],
              ),
            );
          } else {
            Widget? child;
            bool reverse = false;
            final segments =
                uri?.path.replaceFirst(RegExp(r'/client/\d+'), '').split('/');
            if (segments == null) {
              child = main;
            } else {
              segments.removeWhere((element) => element.isEmpty);
              if (segments.length < 2) {
                child = main;
                reverse = true;
              }
            }
            child ??= secondary ?? main;

            return _buildAnimation(context, child, reverse);
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
