import 'package:flutter/material.dart';

class AsciiProgressIndicator extends StatefulWidget {
  const AsciiProgressIndicator({super.key});

  @override
  State<AsciiProgressIndicator> createState() => _AsciiProgressIndicatorState();
}

class _AsciiProgressIndicatorState extends State<AsciiProgressIndicator>
    with TickerProviderStateMixin {
  static final characters = List.generate(
    256,
    (index) => _twoCharacters(index.toRadixString(16)),
  );

  static String _twoCharacters(String input) {
    final long = '0$input';
    return long.substring(long.length - 2);
  }

  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
      lowerBound: 0,
      upperBound: characters.length.toDouble() - 1,
    )..repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const CircularProgressIndicator(
              strokeWidth: 2,
            ),
            Semantics(
              excludeSemantics: true,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, _) {
                  final rounded = controller.value.round();
                  final character = characters[rounded];
                  return Text(
                    character,
                    style: Theme.of(context).textTheme.titleSmall,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
