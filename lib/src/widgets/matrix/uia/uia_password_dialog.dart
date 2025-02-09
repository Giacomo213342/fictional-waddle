import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../client_scope.dart';

class UiaPasswordDialog extends StatefulWidget {
  const UiaPasswordDialog({
    super.key,
    required this.request,
    required this.client,
  });

  final UiaRequest request;
  final Client client;

  Future<String?> show(BuildContext context) {
    return showAdaptiveDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ClientScope(
        client: client,
        child: this,
      ),
    );
  }

  @override
  State<UiaPasswordDialog> createState() => _UiaPasswordDialogState();
}

class _UiaPasswordDialogState extends State<UiaPasswordDialog> {
  TextEditingController controller = TextEditingController();
  bool _hideInput = true;

  @override
  Widget build(BuildContext context) {
    final userId = widget.client.userID;
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).authenticationRequired),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 256 + 128),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userId != null) ...[
              Text(AppLocalizations.of(context).authenticateForAccount(userId)),
              const SizedBox(height: 16),
            ],
            TextField(
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
          ],
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
