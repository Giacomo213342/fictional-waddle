import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';

class AskWipeSsssWidget extends StatelessWidget {
  const AskWipeSsssWidget({super.key});

  static Future<bool?> show(BuildContext context) => showAdaptiveDialog<bool>(
        context: context,
        builder: (context) => const AskWipeSsssWidget(),
      );

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(AppLocalizations.of(context).wipeAccount),
      content: Text(AppLocalizations.of(context).wipeAccountWarning),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(AppLocalizations.of(context).deleteAll),
        ),
      ],
    );
  }
}
