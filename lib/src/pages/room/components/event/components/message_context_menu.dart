import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/dynamic_context_menu.dart';
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
  @override
  Widget build(BuildContext context) {
    return DynamicContextMenu(
      itemBuilder: _getContextMenuButtons,
      previewBuilder: (context, constraints) => ReplyContainer(
        replyEvent: widget.event,
        globalKeySuffix: 'context',
        constraints: constraints,
      ),
      child: Dismissible(
        key: Key(widget.event.eventId),
        confirmDismiss: (_) async {
          _replyMessage();
          return false;
        },
        direction: DismissDirection.startToEnd,
        child: widget.child,
      ),
    );
  }

  Future<void> _redactMessage() async {
    final response = await showAdaptiveDialog(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(
          AppLocalizations.of(context).confirmRedact,
        ),
        content: Text(
          AppLocalizations.of(context).redactEventLong(
            widget.event.eventId,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context).cancel,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              AppLocalizations.of(context).redact,
            ),
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

  void _reactMessage() {
    RoomController.of(context).setReplyEvent(widget.event);
    const reactionPrefix = '/react :';
    RoomController.of(context).messageController.value = const TextEditingValue(
      text: reactionPrefix,
      composing: TextRange.collapsed(reactionPrefix.length),
    );
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
        icon: Icons.copy,
      ),
      if (room.canSendDefaultMessages)
        ContextMenuItem(
          onPressed: _replyMessage,
          label: AppLocalizations.of(context).reply,
          type: ContextMenuButtonType.custom,
          icon: Icons.reply,
        ),
      if (room.canSendEvent(EventTypes.Reaction))
        ContextMenuItem(
          onPressed: _reactMessage,
          label: AppLocalizations.of(context).react,
          type: ContextMenuButtonType.custom,
          icon: Icons.emoji_emotions,
        ),
      if (widget.event.senderId == room.client.userID)
        ContextMenuItem(
          onPressed: _editMessage,
          label: AppLocalizations.of(context).edit,
          type: ContextMenuButtonType.custom,
          icon: Icons.edit,
        ),
      if (widget.event.canRedact)
        ContextMenuItem(
          onPressed: _redactMessage,
          label: AppLocalizations.of(context).redact,
          type: ContextMenuButtonType.delete,
          isDestructiveAction: true,
          icon: Icons.delete_forever,
        ),
    ];
  }
}
