import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../intent_manager.dart';

class ShareFilesText extends StatelessWidget {
  const ShareFilesText({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: IntentManager.sharedFilesListener,
      builder: (context, files, _) => Text(
        AppLocalizations.of(context).sharingFiles(files?.length ?? 0),
      ),
    );
  }
}
