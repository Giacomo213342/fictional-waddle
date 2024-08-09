import 'package:flutter/material.dart';

const _kDefaultPadding =
    EdgeInsets.only(left: 24.0, top: 8.0, right: 24.0, bottom: 24.0);

class PolyculeOverflowBar extends StatelessWidget {
  const PolyculeOverflowBar({
    super.key,
    this.alignment = MainAxisAlignment.end,
    this.overflowAlignment = OverflowBarAlignment.end,
    this.overflowDirection = VerticalDirection.down,
    required this.children,
  });

  final MainAxisAlignment alignment;
  final OverflowBarAlignment overflowAlignment;
  final VerticalDirection overflowDirection;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Theme.of(context).dialogTheme.actionsPadding ?? _kDefaultPadding,
      child: OverflowBar(
        spacing: 8.0,
        overflowSpacing: 8.0,
        overflowAlignment: overflowAlignment,
        overflowDirection: overflowDirection,
        alignment: alignment,
        children: children,
      ),
    );
  }
}
