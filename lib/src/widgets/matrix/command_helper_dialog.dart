import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../theme/fonts.dart';
import '../../utils/matrix/command_localization_helper.dart';
import 'matrix_scope.dart';

class CommandHelperDialog extends StatelessWidget {
  const CommandHelperDialog({super.key, required this.client});

  final Client client;

  @override
  Widget build(BuildContext context) {
    final helper = CommandLocalizationHelper(AppLocalizations.of(context));
    return SimpleDialog(
      title: Text(AppLocalizations.of(context).availableCommands),
      children: client.commands.keys.map((command) {
        final description = helper.lookupCommandDescription(command);
        return CommandListTile(
          command: command,
          description: description,
        );
      }).toList(),
    );
  }

  Future<String?> show(BuildContext context) async {
    final scope = MatrixScope.captureAll(context);
    return showAdaptiveDialog<String>(
      context: context,
      useRootNavigator: true,
      builder: (context) => MatrixScope(
        scope: scope,
        child: this,
      ),
    );
  }
}

class CommandListTile extends StatelessWidget {
  const CommandListTile({super.key, required this.command, this.description});

  final String command;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    final displayCommand = r'/' + command;
    return ListTile(
      title: Text(
        displayCommand,
        style: TextStyle(fontFamily: PolyculeFonts.notoSansMono.name),
      ),
      subtitle: description == null ? null : Text(description),
      onTap: () {
        Clipboard.setData(ClipboardData(text: displayCommand));
        Navigator.of(context).pop(displayCommand);
      },
    );
  }
}
