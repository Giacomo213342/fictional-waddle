import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

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
    return SelectionArea(
      child: MxcEncryptedFileBuilder<MatrixFile, MatrixFile>(
        event: widget.event,
        thumbnail: ThumbnailRequest.attachmentOnly,
        builder: (context, thumbnail, attachment, retryCallback) {
          return ListTile(
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
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
