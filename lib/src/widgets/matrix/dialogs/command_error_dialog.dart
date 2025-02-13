import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/fonts.dart';
import '../scopes/matrix_scope.dart';

class CommandErrorDialog extends StatelessWidget {
  const CommandErrorDialog({super.key, required this.error});

  final CommandException error;

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).commandError),
      content: Text(
        error.message,
        style: TextStyle(fontFamily: PolyculeFonts.notoSansMono.name),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
      ],
    );
  }

  Future<String?> show(BuildContext context) async {
    final scope = MatrixScope.captureAll(context);
    return showAdaptiveDialog<String>(
      context: context,
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
