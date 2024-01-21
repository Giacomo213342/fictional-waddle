import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';

class SyncUpdateStatusRow extends StatefulWidget {
  const SyncUpdateStatusRow({
    super.key,
    required this.syncUpdate,
    required this.timestamp,
  });

  final SyncUpdate? syncUpdate;
  final DateTime timestamp;

  @override
  State<SyncUpdateStatusRow> createState() => _SyncUpdateStatusRowState();
}

class _SyncUpdateStatusRowState extends State<SyncUpdateStatusRow> {
  Duration? offset;

  @override
  Widget build(BuildContext context) {
    final offset = this.offset;
    final isOffline = offset != null && offset.inSeconds > 30;
    return IconTheme(
      data: IconThemeData(
        size: 16,
        color: DefaultTextStyle.of(context).style.color,
      ),
      child: SafeArea(
        child: Row(
          children: widget.syncUpdate == null
              ? [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Tooltip(
                      message: AppLocalizations.of(context).initialSync,
                      child: const Icon(
                        Icons.sync_lock,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                  Text(AppLocalizations.of(context).syncInProgress),
                ]
              : [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: isOffline
                        ? Tooltip(
                            message: AppLocalizations.of(context).syncOffline,
                            child: Icon(
                              Icons.sync_problem,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          )
                        : Tooltip(
                            message:
                                AppLocalizations.of(context).syncFunctional,
                            child: const Icon(
                              Icons.sync,
                              color: Colors.green,
                            ),
                          ),
                  ),
                  Text(
                    AppLocalizations.of(context).lastSyncReceived(
                      widget.timestamp,
                      offset?.inMilliseconds ?? 0,
                    ),
                  ),
                ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant SyncUpdateStatusRow oldWidget) {
    if (oldWidget.timestamp != widget.timestamp) {
      setState(() {
        offset = widget.timestamp.difference(oldWidget.timestamp);
      });
    }
    super.didUpdateWidget(oldWidget);
  }
}
