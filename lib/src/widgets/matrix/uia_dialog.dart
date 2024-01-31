import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../l10n/generated/app_localizations.dart';

class UiaDialog extends StatefulWidget {
  const UiaDialog({super.key, required this.request});

  final UiaRequest request;

  Future<String?> show(BuildContext context) => showDialog<String?>(
        context: context,
        barrierDismissible: false,
        builder: (context) => this,
      );

  @override
  State<UiaDialog> createState() => _UiaDialogState();
}

class _UiaDialogState extends State<UiaDialog> {
  TextEditingController controller = TextEditingController();
  bool _hideInput = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).authenticationRequired),
      content: TextField(
        controller: controller,
        onSubmitted: (_) => _submit(),
        obscureText: _hideInput,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: AppLocalizations.of(context).password,
          suffixIcon: IconButton(
            tooltip: AppLocalizations.of(context).togglePassword,
            onPressed: _toggleHidden,
            icon: Icon(
              _hideInput ? Icons.visibility : Icons.visibility_off,
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(AppLocalizations.of(context).submit),
        ),
      ],
    );
  }

  void _toggleHidden() => setState(() => _hideInput = !_hideInput);

  void _submit() {
    final password = controller.text;

    Navigator.of(context).pop(password);
  }
}
