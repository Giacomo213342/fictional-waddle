import 'package:flutter/material.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../client_back_button.dart';
import 'client_tab_bar.dart';

class KeyboardAwareTopBar extends StatelessWidget {
  const KeyboardAwareTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, visible) => AnimatedSize(
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: SafeArea(
          top: !visible,
          child: SizedBox(
            height: visible ? 0 : 48,
            child: const ClipRect(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    ClientBackButton(),
                    SizedBox(width: 8),
                    Expanded(child: ClientTabBar()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
