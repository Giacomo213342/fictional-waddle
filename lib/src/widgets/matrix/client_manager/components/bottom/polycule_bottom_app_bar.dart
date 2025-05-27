import 'package:flutter/material.dart';

import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import '../client_back_button.dart';
import '../top/client_tab_bar.dart';
import 'client_switcher_button.dart';

class PolyculeBottomAppBar extends StatelessWidget {
  const PolyculeBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardVisibilityBuilder(
      builder: (context, visible) => AnimatedSize(
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: SafeArea(
          top: false,
          bottom: !visible,
          child: SizedBox(
            height: visible ? 0 : 64,
            child: ClipRect(
              child: Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                clipBehavior: Clip.hardEdge,
                child: const Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: ClientBackButton(),
                    ),
                    Expanded(
                      child: ClientTabBar(),
                    ),
                    SizedBox(
                      width: 64,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.0),
                          child: ClientSwitcherButton(),
                        ),
                      ),
                    ),
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
