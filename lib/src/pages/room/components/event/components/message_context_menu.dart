import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../room.dart';
import '../m_reply_container.dart';

class MessageContextMenu extends StatefulWidget {
  const MessageContextMenu({
    super.key,
    required this.child,
    required this.event,
  });

  final Widget child;
  final Event event;

  @override
  State<MessageContextMenu> createState() => _MessageContextMenuState();
}

class _MessageContextMenuState extends State<MessageContextMenu> {
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
    final child = Dismissible(
      key: Key(widget.event.eventId),
      confirmDismiss: (_) async {
        _replyMessage();
        return false;
      },
      /* background: IconTheme(
        data: IconTheme.of(context).copyWith(size: 16),
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.reply),
              Icon(Icons.reply),
            ],
          ),
        ),
      ), */
      child: widget.child,
    );
    /* if (!kIsWeb && Platform.isIOS) {
      return CupertinoContextMenu(
        actions: _getContextMenuButtons()
            .map(
              (item) => CupertinoContextMenuAction(
                trailingIcon: item.icon,
                isDestructiveAction: item.isDestructiveAction,
                child: Text(item.label),
              ),
            )
            .toList(),
        enableHapticFeedback: true,
        child: InheritedTheme.captureAll(context, child),
      );
    } */
    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onSecondaryTapUp: _secondaryTap,
      onSecondaryTap: () {},
      onLongPress: _longPress,
      onTap: _onTap,
      child: child,
    );
  }

  void _onTap() {
    ContextMenuController.removeAny();
  }

  void _secondaryTap(TapUpDetails details) {
    controller.show(
      context: context,
      contextMenuBuilder: (context) {
        return AdaptiveTextSelectionToolbar.buttonItems(
          anchors: TextSelectionToolbarAnchors(
            primaryAnchor: details.globalPosition,
          ),
          buttonItems: _getContextMenuButtons()
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
    final items = _getContextMenuButtons();
    await showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ReplyContainer(
                    replyEvent: widget.event,
                    globalKeySuffix: 'context',
                    constraints: constraints,
                  );
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

  Future<void> _redactMessage() async {
    final response = await showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context).confirmRedact),
        content: Text(
          AppLocalizations.of(context).redactEventLong(widget.event.eventId),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(AppLocalizations.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(AppLocalizations.of(context).redact),
          ),
        ],
      ),
    );
    if (response != true) {
      return;
    }
    await widget.event.redactEvent();
  }

  void _editMessage() {
    RoomController.of(context).setEditEvent(widget.event);
  }

  void _replyMessage() {
    RoomController.of(context).setReplyEvent(widget.event);
  }

  Future<void> _copyMessage() async {
    final body = await widget.event.calcLocalizedBody(
      const MatrixDefaultLocalizations(),
      hideReply: true,
    );
    await Clipboard.setData(ClipboardData(text: body));
  }

  List<ContextMenuItem> _getContextMenuButtons() {
    final room = widget.event.room;

    return [
      ContextMenuItem(
        onPressed: _copyMessage,
        label: AppLocalizations.of(context).copyMessage,
        type: ContextMenuButtonType.copy,
      ),
      if (room.canSendDefaultMessages)
        ContextMenuItem(
          onPressed: _replyMessage,
          label: AppLocalizations.of(context).reply,
          type: ContextMenuButtonType.custom,
        ),
      if (widget.event.senderId == room.client.userID)
        ContextMenuItem(
          onPressed: _editMessage,
          label: AppLocalizations.of(context).edit,
          type: ContextMenuButtonType.custom,
        ),
      if (widget.event.canRedact)
        ContextMenuItem(
          onPressed: _redactMessage,
          label: AppLocalizations.of(context).redact,
          type: ContextMenuButtonType.delete,
          isDestructiveAction: true,
        ),
    ];
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
