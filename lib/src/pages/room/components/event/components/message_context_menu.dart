import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../../widgets/dynamic_context_menu.dart';
import '../../../../../widgets/matrix/event_source_code_dialog.dart';
import '../../../../../widgets/matrix/matrix_scope.dart';
import '../../../room.dart';
import '../quoted_event.dart';

class MessageContextMenu extends StatelessWidget {
  const MessageContextMenu({
    super.key,
    required this.child,
    required this.event,
  });

  final Widget child;
  final Event event;

  @override
  Widget build(BuildContext context) {
    return DynamicContextMenu(
      itemBuilder: () => _getContextMenuButtons(context),
      previewBuilder: (context) => const QuotedEvent(),
      child: Dismissible(
        key: Key(event.eventId),
        confirmDismiss: (_) async {
          _replyMessage(context);
          return false;
        },
        direction: DismissDirection.startToEnd,
        child: child,
      ),
    );
  }

  Future<void> _redactMessage(BuildContext context) async {
    final scope = MatrixScope.captureAll(context);
    final response = await showAdaptiveDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => MatrixScope(
        scope: scope,
        child: AlertDialog.adaptive(
          title: Text(
            AppLocalizations.of(context).confirmRedact,
          ),
          content: Text(
            AppLocalizations.of(context).redactEventLong(
              event.eventId,
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
      ),
    );
    if (response != true) {
      return;
    }
    await event.redactEvent();
  }

  Future<void> _viewSourceCode(BuildContext context) =>
      const EventSourceCodeDialog().showDialog(context: context);

  void _editMessage(BuildContext context) {
    RoomController.of(context).setEditEvent(event);
  }

  void _replyMessage(BuildContext context) {
    RoomController.of(context).setReplyEvent(event);
  }

  void _reactMessage(BuildContext context) {
    RoomController.of(context).setReplyEvent(event);
    const reactionPrefix = '/react :';
    RoomController.of(context).messageController.value = const TextEditingValue(
      text: reactionPrefix,
      composing: TextRange.collapsed(reactionPrefix.length),
    );
  }

  Future<void> _copyMessage(BuildContext context) async {
    final body = await event.calcLocalizedBody(
      AppLocalizations.of(context).matrix,
      hideReply: true,
    );
    await Clipboard.setData(ClipboardData(text: body));
  }

  List<ContextMenuItem> _getContextMenuButtons(BuildContext context) {
    final room = event.room;

    return [
      ContextMenuItem(
        onPressed: () => _copyMessage(context),
        label: AppLocalizations.of(context).copyMessage,
        type: ContextMenuButtonType.copy,
        icon: Icons.copy,
      ),
      if (room.canSendDefaultMessages)
        ContextMenuItem(
          onPressed: () => _replyMessage(context),
          label: AppLocalizations.of(context).reply,
          type: ContextMenuButtonType.custom,
          icon: Icons.reply,
        ),
      if (room.canSendEvent(EventTypes.Reaction))
        ContextMenuItem(
          onPressed: () => _reactMessage(context),
          label: AppLocalizations.of(context).react,
          type: ContextMenuButtonType.custom,
          icon: Icons.emoji_emotions,
        ),
      if (event.senderId == room.client.userID)
        ContextMenuItem(
          onPressed: () => _editMessage(context),
          label: AppLocalizations.of(context).edit,
          type: ContextMenuButtonType.custom,
          icon: Icons.edit,
        ),
      ContextMenuItem(
        onPressed: () => _viewSourceCode(context),
        label: AppLocalizations.of(context).viewSourceCode,
        type: ContextMenuButtonType.custom,
        icon: Icons.developer_mode,
      ),
      if (event.canRedact)
        ContextMenuItem(
          onPressed: () => _redactMessage(context),
          label: AppLocalizations.of(context).redact,
          type: ContextMenuButtonType.delete,
          isDestructiveAction: true,
          icon: Icons.delete_forever,
        ),
    ];
  }
}
