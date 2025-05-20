import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:async/async.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:matrix/matrix.dart';

import '../../../../utils/matrix/database_drafts.dart';
import '../../../../widgets/intent_manager.dart';
import '../../../../widgets/matrix/dialogs/command_error_dialog.dart';
import '../../../../widgets/matrix/dialogs/command_helper_dialog.dart';
import '../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import 'send_file_scope.dart';
import 'type_ahead_helper.dart';

class ComposeScopeWidget extends StatefulWidget {
  const ComposeScopeWidget({super.key, required this.child});

  final Widget child;

  @override
  State<ComposeScopeWidget> createState() => ComposeScope();
}

class _ComposeScope extends InheritedWidget {
  const _ComposeScope({
    required this.scope,
    required super.child,
  });

  final ComposeScope scope;

  @override
  bool updateShouldNotify(covariant _ComposeScope oldWidget) {
    return scope.editEvent != oldWidget.scope.editEvent ||
        scope.replyEvent == oldWidget.scope.replyEvent;
  }
}

class ComposeScope extends State<ComposeScopeWidget> {
  static ComposeScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_ComposeScope>()!.scope;

  Event? _editEvent;
  Event? _replyEvent;

  Event? get editEvent => _editEvent;

  Event? get replyEvent => _replyEvent;

  final messageController = TextEditingController();
  final msgTypeController = TextEditingController(text: MessageTypes.Text);
  final suggestionsController = SuggestionsController<TypeAheadOption>();

  final focusNode = FocusNode();
  FocusNode? messageFocusNode;

  String _sendMsgType = MessageTypes.Text;

  final Map<String, CancelableOperation<String?>> txids = {};

  @override
  void initState() {
    messageFocusNode = FocusNode(
      onKeyEvent: _handleMessageKeyEvent,
    );

    messageController.addListener(_adjustMessageType);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDraft();
    });
    super.initState();
  }

  @override
  void dispose() {
    messageController.removeListener(_adjustMessageType);
    messageController.removeListener(_storeDraft);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ComposeScope(
        scope: this,
        child: SendFileScopeWidget(child: widget.child),
      );

  Future<void> sendMessage() async {
    final room = RoomScope.of(context).room;
    String message = messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    final msgType = _sendMsgType;
    final editEvent = this.editEvent;
    final replyEvent = this.replyEvent;
    messageController.text = '';
    setState(() {
      _sendMsgType = MessageTypes.Text;
      _replyEvent = null;
      _editEvent = null;
    });
    try {
      String? eventId;
      // some joke enabling to send notices ...
      if (msgType == MessageTypes.Notice) {
        final event = <String, String>{
          'msgtype': msgType,
          'body': message,
        };
        eventId = await room.sendEvent(
          event,
          inReplyTo: replyEvent,
          editEventId: editEvent?.eventId,
        );
      } else {
        final isCommand = message.startsWith('/');
        final stdout = StringBuffer();

        eventId = await room.sendTextEvent(
          message,
          inReplyTo: replyEvent,
          editEventId: editEvent?.eventId,
          commandStdout: stdout,
        );

        if (isCommand) {
          if (!mounted) {
            return;
          }
          final command = message.split(' ').first;
          if (command == '/help') {
            final selectedCommand =
                await CommandHelperDialog(client: room.client).show(context);
            if (selectedCommand == null) {
              return;
            }
            message = message.replaceFirst('/help', selectedCommand);
            throw Exception('Help command selected');
          }
          String result = stdout.toString();
          if (result.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result),
              ),
            );
          }
        }
      }
      if (eventId != null) {
        if (IntentManager.sharedTextListener.value != null) {
          await IntentManager.claimShareIntent();
        }
      }
    } on CommandException catch (e) {
      setState(() {
        _sendMsgType = msgType;
        _editEvent = editEvent;
        _replyEvent = replyEvent;
      });
      messageController.text = message;
      if (mounted) {
        await CommandErrorDialog(error: e).show(context);
      }
      rethrow;
    } catch (_) {
      setState(() {
        _sendMsgType = msgType;
        _editEvent = editEvent;
        _replyEvent = replyEvent;
      });
      messageController.text = message;
      rethrow;
    }
  }

  void setSendMsgType([String? msgType]) {
    setState(() {
      _sendMsgType = msgType ?? MessageTypes.Text;
    });
    switch (_sendMsgType) {
      case MessageTypes.Emote:
        if (!messageController.text.startsWith('/me')) {
          messageController.value = messageController.value.replaced(
            const TextRange(start: 0, end: 0),
            '/me ',
          );
        }
        break;
      case MessageTypes.Text:
      case MessageTypes.Notice:
        if (messageController.text.startsWith('/me')) {
          messageController.value = messageController.value.replaced(
            TextRange(start: 0, end: min(4, messageController.text.length)),
            '',
          );
        }
        break;
    }
    msgTypeController.text = _sendMsgType;
  }

  void clearRelatedEvent() {
    if (editEvent != null) {
      messageController.clear();
    }
    setState(() {
      _replyEvent = null;
      _editEvent = null;
    });
  }

  void setReplyEvent(Event event) {
    setState(() {
      _replyEvent = event;
      _editEvent = null;
    });
    messageFocusNode?.requestFocus();
  }

  void setEditEvent(Event event) {
    messageController.text = event.body.replaceFirst(
      RegExp(r'^>( \*)? <[^>]+>[^\n\r]+\r?\n(> [^\n]*\r?\n)*\r?\n'),
      '',
    );
    setState(() {
      _replyEvent = null;
      _editEvent = event;
    });
    setSendMsgType(event.messageType);
    messageFocusNode?.requestFocus();
  }

  void _adjustMessageType() {
    if (messageController.text.startsWith('/me') &&
        _sendMsgType != MessageTypes.Emote) {
      setSendMsgType(MessageTypes.Emote);
    } else if (_sendMsgType == MessageTypes.Emote &&
        !messageController.text.startsWith('/me')) {
      setSendMsgType(MessageTypes.Text);
    }
  }

  Future<void> cancelSend(Event event) async {
    final room = RoomScope.of(context).room;
    final txid = event.eventId;

    await txids[txid]?.cancel();
    txids.remove(txid);

    room.sendingFilePlaceholders.remove(txid);
    room.sendingFileThumbnails.remove(txid);

    return event.cancelSend();
  }

  KeyEventResult _handleMessageKeyEvent(FocusNode node, KeyEvent event) {
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        // ensure we don't react to on-screen keyboards here
        HardwareKeyboard.instance
            .isLogicalKeyPressed(LogicalKeyboardKey.enter) &&
        !HardwareKeyboard.instance.isShiftPressed &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isAltPressed) {
      final firstSuggestion = suggestionsController.suggestions?.firstOrNull;
      if (firstSuggestion == null) {
        sendMessage();
      }

      return KeyEventResult.handled;
    } else {
      return KeyEventResult.ignored;
    }
  }

  Future<void> _loadDraft() async {
    final room = RoomScope.of(context).room;
    final client = ClientScope.of(context).client;
    final draft = await client.database.getRoomDraft(room.id);
    if (draft != null) {
      messageController.value = TextEditingValue(
        text: draft,
        composing: TextRange.collapsed(draft.length),
      );
    }

    messageController.addListener(_storeDraft);
  }

  Future<void> _storeDraft() async {
    final room = RoomScope.of(context).room;
    final client = ClientScope.of(context).client;

    final draft = messageController.text;
    await client.database.storeRoomDraft(room.id, draft);
  }
}
