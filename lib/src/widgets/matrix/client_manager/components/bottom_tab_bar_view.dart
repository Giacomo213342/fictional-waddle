import 'package:flutter/material.dart';

import 'bottom/client_switcher_button.dart';
import 'bottom/client_tab_bar.dart';
import 'client_back_button.dart';

class BottomTabBarView extends StatelessWidget {
  const BottomTabBarView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: child,
        floatingActionButton: const ClientSwitcherButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        bottomNavigationBar: BottomAppBar(
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
              SizedBox(width: 64),
            ],
          ),
        ),
      );
}
