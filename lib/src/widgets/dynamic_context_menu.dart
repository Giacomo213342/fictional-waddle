import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef DynamicContextMenuItemBuilder = List<ContextMenuItem> Function();

class DynamicContextMenu extends StatefulWidget {
  const DynamicContextMenu({
    super.key,
    required this.itemBuilder,
    required this.child,
    this.previewBuilder,
    this.focusNode,
    this.onTap,
    this.onSecondaryTap,
  });

  final Widget child;
  final DynamicContextMenuItemBuilder itemBuilder;
  final LayoutWidgetBuilder? previewBuilder;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;

  @override
  State<DynamicContextMenu> createState() => _DynamicContextMenuState();
}

class _DynamicContextMenuState extends State<DynamicContextMenu> {
  final controller = ContextMenuController();

  @override
  void initState() {
    super.initState();
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }
  }

  @override
  void dispose() {
    if (kIsWeb) {
      BrowserContextMenu.enableContextMenu();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb && Platform.isIOS) {
      return LayoutBuilder(
        builder: (context, constraints) => CupertinoContextMenu.builder(
          actions: widget.itemBuilder
              .call()
              .map(
                (item) => Builder(
                  builder: (context) {
                    return CupertinoContextMenuAction(
                      trailingIcon: item.icon,
                      isDestructiveAction: item.isDestructiveAction,
                      onPressed: () {
                        item.onPressed();
                        Navigator.pop(context);
                      },
                      child: Text(item.label),
                    );
                  },
                ),
              )
              .toList(),
          enableHapticFeedback: true,
          builder: (innerContext, animation) => AnimatedBuilder(
            animation: animation,
            builder: (BuildContext context, Widget? child) => Padding(
              padding: EdgeInsets.all(animation.value * 16),
              child: animation.value > CupertinoContextMenu.animationOpensAt
                  ? Material(
                      color: Theme.of(context).colorScheme.surface,
                      clipBehavior: Clip.hardEdge,
                      child:
                          widget.previewBuilder?.call(context, constraints) ??
                              widget.child,
                    )
                  : Material(
                      color: Colors.transparent,
                      clipBehavior: Clip.hardEdge,
                      child: child,
                    ),
            ),
            child: InheritedTheme.captureAll(
              context,
              widget.child,
              // to: innerContext,
            ),
          ),
        ),
      );
    }
    return InkWell(
      focusNode: widget.focusNode,
      canRequestFocus: true,
      onSecondaryTapUp: _secondaryTap,
      onSecondaryTap: widget.onSecondaryTap ?? () {},
      onLongPress: _longPress,
      onTap: _onTap,
      child: widget.child,
    );
  }

  void _onTap() {
    ContextMenuController.removeAny();
    widget.onTap?.call();
  }

  void _secondaryTap(TapUpDetails details) {
    controller.show(
      context: context,
      contextMenuBuilder: (context) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: details.globalPosition,
          ),
          buttonItems: widget.itemBuilder
              .call()
              .map(
                (item) => ContextMenuButtonItem(
                  label: item.label,
                  type: item.type,
                  onPressed: () {
                    ContextMenuController.removeAny();
                    item.onPressed.call();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<void> _longPress() async {
    ContextMenuController.removeAny();
    final items = widget.itemBuilder.call();
    await showModalBottomSheet(
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: LayoutBuilder(
                builder: widget.previewBuilder ??
                    (context, constraints) {
                      return widget.child;
                    },
              ),
            );
          }
          index--;
          final button = items[index];
          final icon = button.icon;
          return ListTile(
            leading: icon != null ? Icon(icon) : null,
            title: Text(button.label),
            onTap: () {
              Navigator.of(context).pop();
              button.onPressed.call();
            },
          );
        },
      ),
    );
  }
}

class ContextMenuItem {
  const ContextMenuItem({
    required this.label,
    this.icon,
    this.type = ContextMenuButtonType.custom,
    this.isDestructiveAction = false,
    required this.onPressed,
  });

  final String label;
  final IconData? icon;
  final ContextMenuButtonType type;
  final bool isDestructiveAction;
  final VoidCallback onPressed;
}
