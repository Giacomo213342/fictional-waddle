import 'dart:math';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../utils/file_selector.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../room_list/room_list.dart';
import 'components/timeline_event_tile.dart';
import 'room_view.dart';

class RoomPage extends StatefulWidget {
  const RoomPage({super.key, required this.room});

  static const pathParameter = 'roomId';

  static String makeRouteName(String roomId) {
    return '${RoomListPage.routeName}/$roomId';
  }

  final Room room;

  @override
  State<RoomPage> createState() => RoomController();
}

class RoomController extends State<RoomPage> {
  final focusNode = FocusNode();

  bool loading = false;

  final messageController = TextEditingController();
  final msgtypeController = TextEditingController(text: MessageTypes.Text);

  String sendMsgType = MessageTypes.Text;

  final eventKeyRegistry = <int, GlobalKey<TimelineEventTileState>>{};

  Room get room => widget.room;

  @override
  void initState() {
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
  Widget build(BuildContext context) => RoomView(this);

  void focusBack() => RoomListController.getFocusNode(room.id).requestFocus();

  Future<void> knockRoom() => joinRoom();

  Future<void> joinRoom() async {
    setState(() {
      loading = true;
    });
    try {
      await room.join();
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
    final message = messageController.text.trim();
    if (message.isEmpty) {
      return;
    }
    final msgType = sendMsgType;
    messageController.text = '';
    setState(() {
      sendMsgType = MessageTypes.Text;
    });
    try {
      // some joke enabling to send notices ...
      if (msgType == MessageTypes.Notice) {
        final event = <String, String>{
          'msgtype': msgType,
          'body': message,
        };
        await room.sendEvent(event);
      } else {
        await room.sendTextEvent(message);
      }
    } catch (_) {
      setState(() {
        sendMsgType = msgType;
      });
      messageController.text = message;
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

  Future<void> sendFileSelection(FileSelector selector) async {
    final selection = await selector.previewSelection(context);
    if (!mounted) {
      return;
    }
    final files = selection?.files;
    if (selection == null || files == null || files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).noFilesSelected),
        ),
      );
      return;
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
      room.sendFileEvent(
        tuple.file,
        thumbnail: tuple.thumbnail,
      );
    }
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
    final message = ClientManager.sharedTextListener.value;
    if (message != null) {
      messageController.text = message;
    }
    final files = ClientManager.sharedFilesListener.value;
    if (files != null) {
      final selector = FileSelector(MessageTypes.File);
      selector.files = files;
      await sendFileSelection(selector);
    } else {
      return;
    }
    if (!mounted) {
      return;
    }
    setSendMsgType();
  }
}
