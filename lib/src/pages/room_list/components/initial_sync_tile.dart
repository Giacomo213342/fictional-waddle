import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';

class InitialSyncTile extends StatelessWidget {
  const InitialSyncTile(this.syncUpdate, {super.key});

  final SyncUpdate? syncUpdate;

  @override
  Widget build(BuildContext context) {
    final expanded = syncUpdate == null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: expanded ? 48 : 0,
      child: ListTile(
        leading: const AsciiProgressIndicator(),
        title: Text(AppLocalizations.of(context).initialSync),
      ),
    );
  }
}
