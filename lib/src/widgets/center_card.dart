import 'package:flutter/material.dart';

class CenterCard extends StatelessWidget {
  const CenterCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 786, maxWidth: 1024),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
          child: child,
        ),
      ),
    );
  }
}
