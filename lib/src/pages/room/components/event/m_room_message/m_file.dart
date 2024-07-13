import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../widgets/matrix/mxc_encrypted_file_builder.dart';

class FileMessage extends StatefulWidget {
  const FileMessage({
    super.key,
    required this.event,
  });

  final Event event;

  @override
  State<FileMessage> createState() => _FileMessageState();
}

class _FileMessageState extends State<FileMessage>
    with
        AutomaticKeepAliveClientMixin<FileMessage>,
        TickerProviderStateMixin<FileMessage> {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SizedBox(
      height: 96,
      child: MxcEncryptedFileBuilder<MatrixFile, MatrixFile>(
        event: widget.event,
        thumbnail: ThumbnailRequest.attachmentOnly,
        builder: (context, thumbnail, attachment, retryCallback) {
          return IntrinsicWidth(
            child: ListTile(
              leading: const Icon(Icons.attach_file),
              title: FutureBuilder<String>(
                future: widget.event
                    .calcLocalizedBody(const MatrixDefaultLocalizations()),
                builder: (context, snapshot) {
                  return Text(
                    attachment.data?.name ??
                        snapshot.data ??
                        widget.event.calcLocalizedBodyFallback(
                          const MatrixDefaultLocalizations(),
                        ),
                  );
                },
              ),
              subtitle: ButtonBar(
                children: [
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.share),
                    tooltip: AppLocalizations.of(context).share,
                  ),
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.save_as),
                    tooltip: AppLocalizations.of(context).saveAs,
                  ),
                  IconButton(
                    onPressed: null,
                    icon: const Icon(Icons.file_download),
                    tooltip: AppLocalizations.of(context).download,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
