import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../scopes/matrix_scope.dart';

class DisplayNameDialog extends StatelessWidget {
  const DisplayNameDialog({super.key, required this.displayName});

  final String displayName;

  Future<String?> show(BuildContext context) async {
    final scope = MatrixScope.captureAll(context);
    return showAdaptiveDialog<String?>(
      context: context,
      useRootNavigator: true,
      builder: (context) => MatrixScope(scope: scope, child: this),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: displayName);
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).yourDisplayName),
      content: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 256 + 96),
        child: TextField(
          autofocus: true,
          controller: controller,
          textInputAction: TextInputAction.send,
          onSubmitted: (name) => Navigator.of(context).pop(name.trim()),
          cursorWidth: 10,
          maxLines: 1,
          maxLength: 256,
          decoration: InputDecoration(
            labelText: AppLocalizations.of(context).displayName,
            border: const OutlineInputBorder(),
            helperText: AppLocalizations.of(context).displayNameHint,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(AppLocalizations.of(context).rename),
        ),
      ],
    );
  }
}
