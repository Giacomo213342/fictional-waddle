import 'package:flutter/material.dart';

import 'package:emoji_extension/emoji_extension.dart';
import 'package:matrix/matrix.dart';

class TypeAheadOption {
  const TypeAheadOption(
    this.name,
    this.range, {
    this.addTrailingSpace = false,
    this.description,
  });

  final String name;
  final String? description;
  final TextRange range;
  final bool addTrailingSpace;
}

class TypeAheadHelper {
  const TypeAheadHelper({
    required this.controller,
    required this.client,
  });

  final TextEditingController controller;
  final Client client;

  Widget itemBuilder(BuildContext context, TypeAheadOption value) {
    final description = value.description;
    return ListTile(
      title: Text(value.name),
      subtitle: description != null ? Text(description) : null,
      dense: true,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget listBuilder(BuildContext context, List<Widget> children) => ListView(
        shrinkWrap: true,
        reverse: true,
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
      option.name,
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
              '/$cmd',
              TextRange(
                start: commandMatch.start,
                end: commandMatch.end,
              ),
              addTrailingSpace: true,
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
        return emojis
            .where(
              (emoji) => emoji.shortcodes.any(
                (code) => code.values.any((code) => code.contains(group)),
              ),
            )
            .map(
              (emoji) => TypeAheadOption(
                emoji.value,
                TextRange(
                  start: emojiMatch.start,
                  end: emojiMatch.end,
                ),
                description: emoji.name,
              ),
            )
            .toList();
      }
    }
    return [];
  }
}
