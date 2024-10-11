import 'package:flutter/material.dart';

import 'package:emoji_extension/emoji_extension.dart';
import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../utils/matrix/command_localization_helper.dart';
import '../../../../widgets/matrix/mxc_uri_image.dart';

class TypeAheadOption {
  const TypeAheadOption(
    this.title,
    this.placeholder,
    this.range, {
    this.addTrailingSpace = false,
    this.description,
  });

  final InlineSpan title;
  final String placeholder;
  final String? description;
  final TextRange range;
  final bool addTrailingSpace;
}

class TypeAheadHelper {
  const TypeAheadHelper({
    required this.controller,
    required this.room,
    required this.l10n,
  });

  final TextEditingController controller;
  final Room room;
  final AppLocalizations l10n;

  Client get client => room.client;

  Widget itemBuilder(BuildContext context, TypeAheadOption value) {
    final description = value.description;
    return ListTile(
      title: Text.rich(value.title),
      subtitle: description != null ? Text(description) : null,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget listBuilder(BuildContext context, List<Widget> children) => ListView(
        shrinkWrap: true,
        children: children,
      );

  List<TypeAheadOption> suggestionsCallback(String search) {
    if (search.isEmpty) {
      return [];
    }

    final selection = controller.value.selection;

    final commandOptions = _commandSuggestions(search, selection);
    if (commandOptions.isNotEmpty) {
      return commandOptions;
    }

    final emojiOptions = _emojiSuggestions(search, selection);
    if (emojiOptions.isNotEmpty) {
      return emojiOptions;
    }

    return [];
  }

  void onSelected(TypeAheadOption option) {
    final value = controller.value;
    String text = value.text.replaceRange(
      option.range.start,
      option.range.end,
      option.placeholder,
    );
    int lengthOffset = value.text.length - text.length;
    if (option.addTrailingSpace) {
      lengthOffset--;
      text += ' ';
    }
    final selection = value.selection.copyWith(
      baseOffset: value.selection.baseOffset - lengthOffset,
      extentOffset: value.selection.extentOffset - lengthOffset,
    );
    controller.value = TextEditingValue(
      text: text,
      selection: selection,
      composing: value.composing,
    );
  }

  List<TypeAheadOption> _commandSuggestions(
    String search,
    TextSelection selection,
  ) {
    final cmdL10nHelper = CommandLocalizationHelper(l10n);
    final commandRegex = RegExp(r'^/(\w+)');
    final commandMatch = commandRegex.firstMatch(search);
    final commandGroup = commandMatch?.group(1);
    if (commandMatch != null &&
        commandGroup != null &&
        selection.start <= commandMatch.end &&
        selection.end >= commandMatch.start) {
      return client.commands.keys
          .where((cmd) => cmd.startsWith(commandGroup))
          .map(
            (cmd) => TypeAheadOption(
              TextSpan(text: '/$cmd'),
              '/$cmd',
              TextRange(
                start: commandMatch.start,
                end: commandMatch.end,
              ),
              addTrailingSpace: true,
              description: cmdL10nHelper.lookupCommandDescription(cmd),
            ),
          )
          .toList();
    }
    return [];
  }

  List<TypeAheadOption> _emojiSuggestions(
    String search,
    TextSelection selection,
  ) {
    final emojis = Emojis.all.where((emoji) => emoji.skinTone == null).toList();

    final emojiRegex = RegExp(r':([\w-]+)');
    final matches = emojiRegex.allMatches(search).toList();
    for (final emojiMatch in matches) {
      final group = emojiMatch.group(1);
      if (group != null &&
          selection.start <= emojiMatch.end &&
          selection.end >= emojiMatch.start) {
        final unicodeOptions = emojis
            .where(
              (emoji) => emoji.shortcodes.any(
                (code) => code.values.any((code) => code.contains(group)),
              ),
            )
            .map(
              (emoji) => TypeAheadOption(
                TextSpan(text: emoji.value),
                emoji.value,
                TextRange(
                  start: emojiMatch.start,
                  end: emojiMatch.end,
                ),
                description: emoji.name,
              ),
            )
            .toList();
        List<TypeAheadOption> customEmoteOptions = [];

        room
            .getImagePacks(ImagePackUsage.emoticon)
            .forEach((imagePackName, imagePack) {
          imagePack.images.forEach((emoteName, content) {
            if (!emoteName.contains(group)) {
              return;
            }
            customEmoteOptions.add(
              TypeAheadOption(
                WidgetSpan(
                  child: MxcUriImageBuilder(
                    key: ValueKey(content.url),
                    uri: content.url,
                    client: client,
                    height: 18,
                    width: 18,
                  ),
                ),
                ':$emoteName:',
                TextRange(
                  start: emojiMatch.start,
                  end: emojiMatch.end,
                ),
                description: '$emoteName - $imagePackName',
              ),
            );
          });
        });

        final emojiOptions = [
          ...unicodeOptions.reversed,
          ...customEmoteOptions.reversed,
        ];
        return emojiOptions;
      }
    }
    return [];
  }
}
