import 'package:flutter/material.dart';

class PolyculeTextShadow extends StatelessWidget {
  const PolyculeTextShadow({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(
        shadows: [
          Shadow(
            blurRadius: .5,
            color: Theme.of(context).colorScheme.surface,
          ),
          Shadow(
            blurRadius: 1.0,
            color: Theme.of(context).colorScheme.surface,
          ),
          Shadow(
            blurRadius: 2.0,
            color: Theme.of(context).colorScheme.surface,
          ),
          Shadow(
            blurRadius: 3.0,
            color: Theme.of(context).colorScheme.surface,
          ),
          Shadow(
            blurRadius: 5.0,
            color: Theme.of(context).colorScheme.surface,
          ),
          Shadow(
            blurRadius: 10.0,
            color: Theme.of(context).colorScheme.surface,
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          return child;
        },
      ),
    );
  }
}
