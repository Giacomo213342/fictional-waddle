import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import 'tab_bottom_sheet.dart';

class ClientSwitcherButton extends StatefulWidget {
  const ClientSwitcherButton({super.key});

  @override
  State<ClientSwitcherButton> createState() => _ClientSwitcherButtonState();
}

class _ClientSwitcherButtonState extends State<ClientSwitcherButton>
    with TickerProviderStateMixin<ClientSwitcherButton> {
  AnimationController? controller;

  @override
  Widget build(BuildContext context) {
    final controller = this.controller ??= AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    return FloatingActionButton.small(
      tooltip: AppLocalizations.of(context).clientSwitcher,
      onPressed: _showMenu,
      child: AnimatedIcon(
        progress: controller,
        icon: AnimatedIcons.menu_close,
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> _showMenu() async {
    controller?.animateTo(1);
    final result = await const TabBottomSheet().show(context);
    controller?.animateBack(0);
    if (result == null || !mounted) {
      return;
    }

    context.push(result);
  }
}
