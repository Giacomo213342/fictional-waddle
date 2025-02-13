import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'matrix/scopes/matrix_scope.dart';

typedef DynamicContextMenuItemBuilder = List<ContextMenuItem> Function();

class DynamicContextMenu extends StatelessWidget {
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
  final WidgetBuilder? previewBuilder;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      BrowserContextMenu.disableContextMenu();
    }

    final scope = MatrixScope.captureAll(context);
    if (!kIsWeb && Platform.isIOS) {
      return LayoutBuilder(
        builder: (context, constraints) => CupertinoContextMenu.builder(
          actions: itemBuilder
              .call()
              .map(
                (item) => Builder(
                  builder: (context) => CupertinoContextMenuAction(
                    trailingIcon: item.icon,
                    isDestructiveAction: item.isDestructiveAction,
                    onPressed: () {
                      item.onPressed();
                      Navigator.pop(context);
                    },
                    child: Text(item.label),
                  ),
                ),
              )
              .toList(),
          enableHapticFeedback: true,
          builder: (_, animation) => AnimatedBuilder(
            animation: animation,
            builder: (_, child) => Padding(
              padding: EdgeInsets.all(animation.value * 16),
              child: MatrixScope(
                scope: scope,
                child: animation.value > CupertinoContextMenu.animationOpensAt
                    ? Material(
                        color: Theme.of(context).colorScheme.surface,
                        clipBehavior: Clip.hardEdge,
                        child: previewBuilder?.call(context) ?? child,
                      )
                    : Material(
                        color: Colors.transparent,
                        clipBehavior: Clip.hardEdge,
                        child: child,
                      ),
              ),
            ),
            child: InheritedTheme.captureAll(
              context,
              InkWell(
                focusNode: focusNode,
                canRequestFocus: true,
                onTap: _onTap,
                child: child,
              ),
              // to: innerContext,
            ),
          ),
        ),
      );
    }
    return InkWell(
      focusNode: focusNode,
      canRequestFocus: true,
      onSecondaryTapUp: (details) => _secondaryTap(context, details),
      onSecondaryTap: onSecondaryTap ?? () {},
      onLongPress: () => _longPress(context, scope),
      onTap: _onTap,
      child: child,
    );
  }

  void _onTap() {
    ContextMenuController.removeAny();
    onTap?.call();
  }

  void _secondaryTap(BuildContext context, TapUpDetails details) {
    ContextMenuController().show(
      context: context,
      contextMenuBuilder: (context) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: details.globalPosition,
          ),
          buttonItems: itemBuilder
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

  Future<void> _longPress(BuildContext context, scope) async {
    ContextMenuController.removeAny();
    final items = itemBuilder.call();
    await showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      clipBehavior: Clip.hardEdge,
      builder: (context) => MatrixScope(
        scope: scope,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: previewBuilder?.call(context) ?? child,
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
