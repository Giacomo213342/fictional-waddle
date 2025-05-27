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
    Widget child;
    final segments =
        uri?.path.replaceFirst(RegExp(r'/client/\d+'), '').split('/');
    if (segments == null) {
      child = main;
    } else {
      segments.removeWhere((element) => element.isEmpty);
      if (segments.length < 2) {
        child = main;
      } else {
        child = secondary ?? main;
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return AdaptiveLayout(
          body: SlotLayout(
            config: {
              Breakpoints.smallAndUp: SlotLayout.from(
                key: const Key('main-body-small'),
                builder: (context) => child,
              ),
              Breakpoints.mediumLargeAndUp: SlotLayout.from(
                key: const Key('main-body'),
                builder: (context) => main,
              ),
            },
          ),
          secondaryBody: SlotLayout(
            config: {
              Breakpoints.mediumLargeAndUp: SlotLayout.from(
                key: const Key('secondary-body'),
                builder: (context) => secondary ?? placeholder,
              ),
            },
          ),
          bodyRatio: constraints.maxWidth < 1200
              ? .5
              : constraints.maxWidth < 1900
                  ? .35
                  : .25,
        );
      },
    );
  }
}
