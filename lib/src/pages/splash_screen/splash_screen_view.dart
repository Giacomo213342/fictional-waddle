import 'package:flutter/material.dart';

import '../../utils/assets.dart';
import '../../widgets/ascii_progress_indicator.dart';

class SplashPageView extends StatelessWidget {
  const SplashPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Hero(
              tag: Assets.logoCircle,
              child: SizedBox.square(
                dimension: 128,
                child: Material(
                  borderRadius: BorderRadius.circular(128),
                  elevation: 4,
                  child: Image.asset(Assets.logoCircle.name),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const AsciiProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
