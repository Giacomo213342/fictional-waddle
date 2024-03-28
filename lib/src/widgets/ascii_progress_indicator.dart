import 'package:flutter/material.dart';

class AsciiProgressIndicator extends StatefulWidget {
  const AsciiProgressIndicator({
    super.key,
    this.progress,
    this.toNextProgressValue = const Duration(milliseconds: 200),
  });

  final double? progress;
  final Duration toNextProgressValue;

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

  double? get progress => widget.progress;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
      lowerBound: 0,
      upperBound: 1,
      value: progress,
    );
    if (widget.progress == null) {
      controller.repeat();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(covariant AsciiProgressIndicator oldWidget) {
    final progress = this.progress;
    if (progress != null && oldWidget.progress != progress) {
      controller.animateTo(progress, duration: widget.toNextProgressValue);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final rounded =
                (controller.value * (characters.length - 1)).floor();
            final character = characters[rounded];

            return Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  value: progress == null ? null : controller.value,
                ),
                Semantics(
                  excludeSemantics: true,
                  child: Text(
                    character,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            );
          },
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
