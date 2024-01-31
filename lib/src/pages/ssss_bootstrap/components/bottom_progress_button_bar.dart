import 'package:flutter/material.dart';

class BottomProgressButtonBar extends StatelessWidget {
  const BottomProgressButtonBar({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(8),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: switch (children.length) {
              1 => children,
              2 => [
                  Expanded(child: children.first),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(child: children.last),
                ],
              int() => [
                  Expanded(
                    child: OverflowBar(
                      children: children,
                    ),
                  ),
                ]
            },
          ),
        ),
      ),
    );
  }
}
