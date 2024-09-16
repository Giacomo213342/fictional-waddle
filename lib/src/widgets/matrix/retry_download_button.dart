import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

class RetryDownloadButton extends StatelessWidget {
  const RetryDownloadButton({super.key, this.callback});

  final VoidCallback? callback;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      runAlignment: WrapAlignment.spaceEvenly,
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          AppLocalizations.of(context).errorDownloadingAttachment,
          textAlign: TextAlign.center,
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
