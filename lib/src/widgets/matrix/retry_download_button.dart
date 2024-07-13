import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class RetryDownloadButton extends StatelessWidget {
  const RetryDownloadButton({super.key, this.callback});

  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            AppLocalizations.of(context).errorDownloadingAttachment,
          ),
        ),
        FloatingActionButton.small(
          tooltip: AppLocalizations.of(context).retry,
          onPressed: callback,
          child: const Icon(Icons.sync_problem),
        ),
      ],
    );
  }
}
