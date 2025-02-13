import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../../l10n/matrix/polycule_matrix_localizations.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';

class FileMessage extends StatelessWidget {
  const FileMessage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    return SelectionArea(
      child: MxcEncryptedFileBuilder<MatrixFile, MatrixFile>(
        event: event,
        thumbnail: ThumbnailRequest.attachmentOnly,
        builder: (context, thumbnail, attachment, retryCallback) => ListTile(
          leading: const Icon(Icons.attach_file),
          title: FutureBuilder<String>(
            future:
                event.calcLocalizedBody(AppLocalizations.of(context).matrix),
            builder: (context, snapshot) => Text(
              attachment.data?.name ??
                  snapshot.data ??
                  event.calcLocalizedBodyFallback(
                    AppLocalizations.of(context).matrix,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
