import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:async/async.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:matrix/matrix.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../utils/file_selector.dart';
import '../../widgets/intent_manager.dart';
import '../../widgets/matrix/dialogs/command_error_dialog.dart';
import '../../widgets/matrix/dialogs/command_helper_dialog.dart';
import '../../widgets/matrix/scopes/room_scope.dart';
import '../room_list/room_list.dart';
import 'components/compose/sticker_pack_bottom_sheet.dart';
import 'components/compose/type_ahead_helper.dart';
import 'room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key});

  static const pathParameter = 'roomId';

  static String makeRouteName(String roomId) {
    return '${RoomListPage.routeName}/${Uri.encodeComponent(roomId)}';
  }

  @override
  State<RoomPage> createState() => RoomController();
}

class _RoomScope extends InheritedWidget {
  const _RoomScope({
    super.key,
    required super.child,
    required RoomController roomState,
  }) : _roomState = roomState;

  final RoomController _roomState;

  @override
  bool updateShouldNotify(_RoomScope old) =>
      _roomState.sendMsgType != old._roomState.sendMsgType ||
      _roomState.replyEvent != old._roomState.replyEvent ||
      _roomState.loading != old._roomState.loading ||
      _roomState.editEvent != old._roomState.editEvent;
}

class RoomController extends State<RoomPage> {
  static RoomController of(BuildContext context) {
    final _RoomScope scope =
        context.dependOnInheritedWidgetOfExactType<_RoomScope>()!;
    return scope._roomState;
  }

  final focusNode = FocusNode();

  bool loading = false;

  final messageController = TextEditingController();
  final msgtypeController = TextEditingController(text: MessageTypes.Text);

  String sendMsgType = MessageTypes.Text;

  final Map<String, CancelableOperation<String?>> txids = {};

  Event? editEvent;
  Event? replyEvent;

  FocusNode? messageFocusNode;

  final suggestionsController = SuggestionsController<TypeAheadOption>();

  @override
  void initState() {
    messageFocusNode = FocusNode(
      onKeyEvent: _handleMessageKeyEvent,
    );

    messageController.addListener(_adjustMessageType);

    WidgetsBinding.instance.addPostFrameCallback((_) => _sendSharedData());

    super.initState();
  }

  @override
  void dispose() {
    messageController.removeListener(_adjustMessageType);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _RoomScope(
        key: ValueKey(
          replyEvent.hashCode *
              editEvent.hashCode *
              loading.hashCode *
              sendMsgType.hashCode,
        ),
        roomState: this,
        child: const RoomView(),
      );

  void focusBack() {
    final room = RoomScope.of(context).room;
    RoomListController.getFocusNode(room.id).requestFocus();
  }

  Future<void> knockRoom() => joinRoom();

  Future<void> joinRoom() async {
    final room = RoomScope.of(context).room;
    setState(() {
      loading = true;
    });
    try {
      await room.join();
      await room.client.waitForRoomInSync(
        room.id,
        join: true,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).youCannotJoinThisRoom,
            ),
          ),
        );
      }
    }

    setState(() {
      loading = false;
    });
  }

  Future<void> sendMessage() async {
    final room = RoomScope.of(context).room;
    String message = messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    final msgType = sendMsgType;
    final editEvent = this.editEvent;
    final replyEvent = this.replyEvent;
    messageController.text = '';
    setState(() {
      sendMsgType = MessageTypes.Text;
      this.replyEvent = null;
      this.editEvent = null;
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
            final selectedCommand = await showCommandHelp();
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
        onMessageSent(eventId);
      }
    } on CommandException catch (e) {
      setState(() {
        sendMsgType = msgType;
        this.editEvent = editEvent;
        this.replyEvent = replyEvent;
      });
      messageController.text = message;
      if (mounted) {
        await CommandErrorDialog(error: e).show(context);
      }
      rethrow;
    } catch (_) {
      setState(() {
        sendMsgType = msgType;
        this.editEvent = editEvent;
        this.replyEvent = replyEvent;
      });
      messageController.text = message;
      rethrow;
    }
  }

  void setSendMsgType([String? msgType]) {
    setState(() {
      sendMsgType = msgType ?? MessageTypes.Text;
    });
    switch (sendMsgType) {
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
    msgtypeController.text = sendMsgType;
  }

  Future<void> sendFile(String? msgType) async {
    final selector = FileSelector(msgType);
    if (await selector.selectFiles(context) != true) {
      return;
    }
    if (!mounted) {
      return;
    }
    await sendFileSelection(selector);
    if (!mounted) {
      return;
    }

    setSendMsgType();
  }

  Future<bool> sendFileSelection(FileSelector selector) async {
    final room = RoomScope.of(context).room;
    final selection = await selector.previewSelection(context);
    if (!mounted) {
      return false;
    }
    final files = selection?.files;
    if (selection == null || files == null || files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noFilesSelected),
        ),
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).sendingFiles(files.length),
        ),
      ),
    );

    final matrixFiles = await selector.makeMatrixFiles(
      context,
      room.client.nativeImplementations,
    );
    for (final tuple in matrixFiles) {
      unawaited(_sendFileTransaction(tuple));
    }
    return true;
  }

  void _adjustMessageType() {
    if (messageController.text.startsWith('/me') &&
        sendMsgType != MessageTypes.Emote) {
      setSendMsgType(MessageTypes.Emote);
    } else if (sendMsgType == MessageTypes.Emote &&
        !messageController.text.startsWith('/me')) {
      setSendMsgType(MessageTypes.Text);
    }
  }

  Future<void> _sendSharedData() async {
    final message = IntentManager.sharedTextListener.value;
    if (message != null) {
      messageController.text = message;
    }
    final files = IntentManager.sharedFilesListener.value;
    if (files != null) {
      final selector = FileSelector(MessageTypes.File);
      selector.files = files;
      final result = await sendFileSelection(selector);
      if (result) {
        await IntentManager.claimShareIntent();
      }
    } else {
      return;
    }
    if (!mounted) {
      return;
    }
    setSendMsgType();
  }

  void onMessageSent(String? eventId) {
    if (eventId == null) {
      return;
    }
    // TODO: maybe do something here
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

  Future<void> _sendFileTransaction(MatrixFileTuple tuple) async {
    final room = RoomScope.of(context).room;
    final txid = room.client.generateUniqueTransactionId();

    final operation = txids[txid] = CancelableOperation.fromFuture(
      room.sendFileEvent(
        tuple.file,
        thumbnail: tuple.thumbnail,
        inReplyTo: replyEvent,
        editEventId: editEvent?.eventId,
        txid: txid,
      ),
    );

    await operation.value;

    txids.remove(txid);
  }

  void clearRelatedEvent() {
    if (editEvent != null) {
      messageController.clear();
    }
    setState(() {
      replyEvent = null;
      editEvent = null;
    });
  }

  void setReplyEvent(Event event) {
    setState(() {
      replyEvent = event;
      editEvent = null;
    });
    messageFocusNode?.requestFocus();
  }

  void setEditEvent(Event event) {
    messageController.text = event.body.replaceFirst(
      RegExp(r'^>( \*)? <[^>]+>[^\n\r]+\r?\n(> [^\n]*\r?\n)*\r?\n'),
      '',
    );
    setState(() {
      replyEvent = null;
      editEvent = event;
    });
    setSendMsgType(event.messageType);
    messageFocusNode?.requestFocus();
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

  Future<String?> showCommandHelp() async {
    final room = RoomScope.of(context).room;
    return await CommandHelperDialog(client: room.client).show(context);
  }

  Future<void> showStickerSelector(String? msgType) async {
    final room = RoomScope.of(context).room;
    final emote = await StickerPackBottomSheet(
      room: room,
    ).showBottomSheet(context);
    setSendMsgType();
    if (emote == null) {
      return;
    }
    await room.sendEvent(
      {
        'body': MessageTypes.Sticker,
        'url': emote.url.toString(),
        'info': emote.info,
      },
      type: MessageTypes.Sticker,
      inReplyTo: replyEvent,
      editEventId: editEvent?.eventId,
    );
  }

  Future<void> sendKeyboardSticker(KeyboardInsertedContent sticker) async {
    final room = RoomScope.of(context).room;
    Uint8List? bytes = sticker.data;
    try {
      if (bytes == null) {
        if (!kIsWeb && Platform.isAndroid) {
          await FileSelector.ensureAndroidInitialized();
          final tmp = await getTemporaryDirectory();
          final file = File(
            '${tmp.path}/import.${extensionFromMime(sticker.mimeType) ?? 'file'}',
          );
          await MediaStore().readFileUsingUri(
            uriString: sticker.uri,
            tempFilePath: file.path,
          );
          bytes = await file.readAsBytes();
        } else {
          return;
        }
      }

      final uri = await room.client.uploadContent(bytes);
      await room.sendEvent(
        {
          'body': MessageTypes.Sticker,
          'url': uri.toString(),
        },
        type: MessageTypes.Sticker,
        inReplyTo: replyEvent,
        editEventId: editEvent?.eventId,
      );
    } catch (e, s) {
      Logs().e('Error sending sticker', e, s);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).errorSendingSticker),
        ),
      );
    }
  }
}
