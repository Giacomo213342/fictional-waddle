import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';

class InitialSyncTile extends StatelessWidget {
  const InitialSyncTile({super.key});

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    return StreamBuilder(
      stream: client.onSyncStatus.stream,
      builder: (context, snapshot) {
        final syncStatus = snapshot.data;
        final hide = client.onSync.value != null &&
            syncStatus?.status != SyncStatus.error &&
            client.prevBatch != null;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: hide ? 0 : 48,
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: ListTile(
              leading: AsciiProgressIndicator(
                progress: hide ? 1 : syncStatus?.progress,
              ),
              title: Text(
                syncStatus?.toLocalizedString(context) ??
                    AppLocalizations.of(context).initialSync,
              ),
            ),
          ),
        );
      },
    );
  }
}

extension on SyncStatusUpdate {
  String toLocalizedString(BuildContext context) {
    switch (status) {
      case SyncStatus.waitingForResponse:
        return AppLocalizations.of(context).initialSync;
      case SyncStatus.error:
        switch (error?.exception) {
          case SyncConnectionException():
            return AppLocalizations.of(context).noHomeserverConnection;
          default:
            return ((error?.exception ?? status) as Object).toString();
        }

      case SyncStatus.processing:
      case SyncStatus.cleaningUp:
      case SyncStatus.finished:
        return AppLocalizations.of(context).syncInProgress;
    }
  }
}
