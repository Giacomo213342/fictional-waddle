import 'dart:collection';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../room.dart';

class MsgtypeDropdown extends StatefulWidget {
  const MsgtypeDropdown({super.key, required this.controller});

  static const _colon = Text(':');

  static const supportedMsgTypes = [
    MessageTypes.Text,
    MessageTypes.Emote,
    MessageTypes.Notice,
    MessageTypes.Image,
    MessageTypes.Video,
    MessageTypes.Audio,
    MessageTypes.File,
    MessageTypes.Sticker,
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
    MessageTypes.BadEncrypted: Icons.lock_open,
    MessageTypes.None: Icons.square,
  };

  final RoomController controller;

  @override
  State<MsgtypeDropdown> createState() => _MsgtypeDropdownState();
}

class _MsgtypeDropdownState extends State<MsgtypeDropdown> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        return DropdownMenu<String>(
          enableSearch: true,
          width: 128 + 32,
          searchCallback: _searchEntries,
          dropdownMenuEntries: _buildDropdownEntries(),
          onSelected: _onMsgTypeSelected,
          trailingIcon: MsgtypeDropdown._colon,
          selectedTrailingIcon: MsgtypeDropdown._colon,
          initialSelection: widget.controller.msgtypeController.text,
          controller: widget.controller.msgtypeController,
          alignmentOffset: _computeScaffoldPositionFix(context),
          inputDecorationTheme: const InputDecorationTheme(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
          ),
        );
      },
    );
  }

  List<DropdownMenuEntry<String>> _buildDropdownEntries() {
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
      MessageTypes.BadEncrypted: l.msgTypeBadEncrypted,
      MessageTypes.None: l.msgTypeNone,
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

  void _onMsgTypeSelected(String? msgType) {
    switch (msgType) {
      case MessageTypes.Text:
      case MessageTypes.Notice:
      case MessageTypes.Emote:
        widget.controller.setSendMsgType(msgType);
        break;
      case MessageTypes.Image:
      case MessageTypes.Video:
      case MessageTypes.Audio:
      case MessageTypes.File:
        widget.controller.sendFile(msgType);
      case MessageTypes.Sticker:
        widget.controller.showStickerSelector(msgType);
      default:
        widget.controller.setSendMsgType(MessageTypes.Text);

        break;
    }
  }

  // Flutter detects the Overlay position relative to the top scaffold. Since we
  // have several scaffold, we need to compute the offset between the primary
  // and secondary scaffold on landscape layout
  Offset? _computeScaffoldPositionFix(BuildContext context) {
    if (MediaQuery.of(context).size.width < 786) {
      return null;
    }
    Rect? rect;
    final box = Scaffold.of(context).context.findRenderObject();
    if (box is RenderBox) {
      rect = box.localToGlobal(Offset.zero) & box.size;
    }
    if (rect == null) {
      return null;
    }
    return Offset(rect.left, -rect.top);
  }
}
