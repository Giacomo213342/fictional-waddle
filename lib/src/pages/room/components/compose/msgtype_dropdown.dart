import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/matrix/scopes/room_scope.dart';
import 'compose_scope.dart';
import 'poll_creation_dialog.dart';
import 'send_file_scope.dart';

class MsgtypeDropdown extends StatelessWidget {
  const MsgtypeDropdown({super.key});

  static const _colon = Text(':');
  static const poll = 'm.poll';

  static const supportedMsgTypes = [
    MessageTypes.Text,
    MessageTypes.Emote,
    MessageTypes.Notice,
    MessageTypes.Image,
    MessageTypes.Video,
    MessageTypes.Audio,
    MessageTypes.File,
    MessageTypes.Sticker,
    poll,
  ];

  static const msgTypesIcons = {
    MessageTypes.Text: Icons.article,
    MessageTypes.Emote: Icons.insert_emoticon,
    MessageTypes.Notice: Icons.smart_toy,
    MessageTypes.Image: Icons.photo_library,
    MessageTypes.Video: Icons.video_library,
    MessageTypes.Audio: Icons.library_music,
    MessageTypes.File: Icons.file_copy,
    MessageTypes.Location: Icons.location_searching,
    MessageTypes.Sticker: Icons.add_reaction,
    poll: Icons.poll_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        return DropdownMenu<String>(
          enableSearch: true,
          width: 128 + 32,
          searchCallback: _searchEntries,
          dropdownMenuEntries: _buildDropdownEntries(context),
          onSelected: (value) => _onMsgTypeSelected(context, value),
          trailingIcon: MsgtypeDropdown._colon,
          selectedTrailingIcon: MsgtypeDropdown._colon,
          initialSelection: ComposeScope.of(context).msgTypeController.text,
          controller: ComposeScope.of(context).msgTypeController,
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
          ),
        );
      },
    );
  }

  List<DropdownMenuEntry<String>> _buildDropdownEntries(BuildContext context) {
    final l = AppLocalizations.of(context);
    final msgTypesTooltips = {
      MessageTypes.Text: l.msgTypeText,
      MessageTypes.Emote: l.msgTypeEmote,
      MessageTypes.Notice: l.msgTypeNotice,
      MessageTypes.Image: l.msgTypeImage,
      MessageTypes.Video: l.msgTypeVideo,
      MessageTypes.Audio: l.msgTypeAudio,
      MessageTypes.File: l.msgTypeFile,
      MessageTypes.Location: l.msgTypeLocation,
      MessageTypes.Sticker: l.msgTypeSticker,
      poll: 'Create poll',
    };
    return UnmodifiableListView(
      MsgtypeDropdown.msgTypesIcons.keys.map(
        (msgType) => DropdownMenuEntry(
          value: msgType,
          enabled: MsgtypeDropdown.supportedMsgTypes.contains(msgType),
          label: msgType,
          leadingIcon: Tooltip(
            message: msgTypesTooltips[msgType],
            child: Icon(MsgtypeDropdown.msgTypesIcons[msgType]),
          ),
        ),
      ),
    );
  }

  int? _searchEntries(List<DropdownMenuEntry<String>> entries, String query) {
    if (query.isEmpty) {
      return null;
    }
    final int index = entries.indexWhere(
      (DropdownMenuEntry<String> entry) => entry.label.contains(query),
    );

    return index != -1 ? index : null;
  }

  void _onMsgTypeSelected(BuildContext context, String? msgType) {
    switch (msgType) {
      case MessageTypes.Text:
      case MessageTypes.Notice:
      case MessageTypes.Emote:
        ComposeScope.of(context).setSendMsgType(msgType);
        break;
      case MessageTypes.Image:
      case MessageTypes.Video:
      case MessageTypes.Audio:
      case MessageTypes.File:
        SendFileScope.of(context).sendFile(msgType);
      case MessageTypes.Sticker:
        SendFileScope.of(context).showStickerSelector(msgType);
      case poll:
        unawaited(_showPollDialog(context));
      default:
        ComposeScope.of(context).setSendMsgType(MessageTypes.Text);
        break;
    }
  }

  Future<void> _showPollDialog(BuildContext context) async {
    final compose = ComposeScope.of(context);
    final room = RoomScope.of(context).room;
    compose.setSendMsgType(MessageTypes.Text);

    // DropdownMenu completes its own selection after invoking onSelected.
    // Wait for that overlay to settle before adding another route, and keep
    // the dialog on the room's Navigator so native back always has one clear
    // owner.
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) {
      return;
    }
    await showDialog<void>(
      context: context,
      useRootNavigator: false,
      builder: (_) => PollCreationDialog(room: room),
    );
    if (context.mounted) {
      // DropdownMenu may have written m.poll into its controller after the
      // callback. Restore the actual composer mode on both send and cancel.
      compose.setSendMsgType(MessageTypes.Text);
    }
  }
}
