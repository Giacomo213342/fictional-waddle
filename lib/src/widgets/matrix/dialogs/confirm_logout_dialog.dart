import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class ConfirmLogoutDialog extends StatelessWidget {
  const ConfirmLogoutDialog({super.key});

  Future<bool?> show(BuildContext context) => showAdaptiveDialog<bool>(
        context: context,
        builder: (context) => this,
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context).logoutWarning),
      content: Text(AppLocalizations.of(context).logoutWarningLong),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(AppLocalizations.of(context).logout),
        ),
      ],
    );
  }
}
