import 'package:flutter/material.dart';

import '../../../utils/assets.dart';

class FadeInLogo extends StatefulWidget {
  const FadeInLogo({super.key});

  @override
  State<FadeInLogo> createState() => _FadeInLogoState();
}

class _FadeInLogoState extends State<FadeInLogo>
    with TickerProviderStateMixin<FadeInLogo> {
  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(vsync: this);
    controller.animateTo(
      1,
      duration: const Duration(seconds: 2),
      curve: Curves.decelerate,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (BuildContext context, Widget? child) => SizedBox.square(
          dimension: controller.value * 64 + 64,
          child: child,
        ),
        child: Center(
          child: Material(
            borderRadius: BorderRadius.circular(128),
            elevation: 4,
            child: Image.asset(Assets.logoCircle.name),
          ),
        ),
      );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
