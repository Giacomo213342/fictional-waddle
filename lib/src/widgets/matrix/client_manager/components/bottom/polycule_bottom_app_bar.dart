import 'package:flutter/material.dart';

import '../client_back_button.dart';
import '../top/client_tab_bar.dart';
import 'client_switcher_button.dart';

class PolyculeBottomAppBar extends StatelessWidget {
  const PolyculeBottomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surfaceContainer,
      notchMargin: 8,
      clipBehavior: Clip.hardEdge,
      child: const Row(
        children: [
          ClientBackButton(),
          SizedBox(width: 8),
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
    );
  }
}
