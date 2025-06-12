import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../utils/dart_environment.dart';
import '../../utils/matrix/autoplay_animated_content_extension.dart';
import 'scopes/client_scope.dart';

typedef AnimatedChildBuilder = Widget Function(
  BuildContext context,
  bool animate,
);

class AnimationEnabledBuilder extends StatefulWidget {
  const AnimationEnabledBuilder({
    super.key,
    required this.builder,
    required this.iconSize,
    this.disableTapHandler = false,
  });

  final AnimatedChildBuilder builder;
  final double iconSize;
  final bool disableTapHandler;

  @override
  State<AnimationEnabledBuilder> createState() =>
      AnimationEnabledBuilderState();
}

class AnimationEnabledBuilderState extends State<AnimationEnabledBuilder> {
  /// whether to animate though autoplay disabled
  bool animating = false;

  @override
  Widget build(BuildContext context) {
    final autoplay = ClientScope.of(context).client.autoplayAnimatedContent ??
        !DartEnvironment.isIntegrationTest;

    final box = widget.builder.call(context, autoplay || animating);

    if (autoplay) {
      return box;
    }

    final textColor = DefaultTextStyle.of(context).style.color;

    return MouseRegion(
      onEnter: startAnimation,
      onHover: startAnimation,
      onExit: stopAnimation,
      child: GestureDetector(
        onTap: widget.disableTapHandler ? null : toggleAnimation,
        child: Stack(
          alignment: Alignment.bottomRight,
          fit: StackFit.loose,
          children: [
            box,
            if (!animating)
              Icon(
                Icons.gif,
                size: widget.iconSize,
                color: textColor,
              ),
          ],
        ),
      ),
    );
  }

  void startAnimation(PointerEvent e) {
    if (e.kind == PointerDeviceKind.mouse) {
      setState(() => animating = true);
    }
  }

  void stopAnimation(PointerEvent e) {
    if (e.kind == PointerDeviceKind.mouse) {
      setState(() => animating = false);
    }
  }

  void toggleAnimation() => setState(() => animating = !animating);

  @override
  void didUpdateWidget(covariant AnimationEnabledBuilder oldWidget) {
    if (oldWidget.builder != widget.builder ||
        oldWidget.iconSize != widget.iconSize) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }
}
