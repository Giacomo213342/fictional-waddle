import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:matrix/matrix.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../utils/file_selector.dart';
import '../../../../../widgets/ascii_progress_indicator.dart';
import '../../../../../widgets/matrix/scopes/matrix_scope.dart';
import '../../../../../widgets/mimed_image.dart';
import '../../../../../widgets/share_origin_builder.dart';

class FullScreenImage extends StatefulWidget {
  const FullScreenImage({super.key, required this.event});

  final Event event;

  static void open(BuildContext context, Event event) {
    final scope = MatrixScope.captureAll(context);
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => MatrixScope(
          scope: scope,
          child: FullScreenImage(event: event),
        ),
      ),
    );
  }

  @override
  State<FullScreenImage> createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  late Future<MatrixFile> _download =
      widget.event.downloadAndDecryptAttachment();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black.withValues(alpha: .45),
        foregroundColor: Colors.white,
        title: Text(
          widget.event.body,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(14),
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            ShareOriginBuilder(
              builder: (context, rect) => IconButton(
                tooltip: AppLocalizations.of(context).share,
                icon: const Icon(Icons.share),
                onPressed: () => _share(rect),
              ),
            ),
            IconButton(
              tooltip: AppLocalizations.of(context).download,
              icon: const Icon(Icons.download),
              onPressed: _save,
            ),
          ],
        ],
      ),
      body: FutureBuilder<MatrixFile>(
        future: _download,
        builder: (context, snapshot) {
          final file = snapshot.data;
          if (snapshot.hasError) {
            return Center(
              child: IconButton.filledTonal(
                tooltip: AppLocalizations.of(context).retry,
                icon: const Icon(Icons.refresh),
                onPressed: () => setState(
                  () => _download = widget.event.downloadAndDecryptAttachment(),
                ),
              ),
            );
          }
          if (file == null) {
            return const Center(child: AsciiProgressIndicator());
          }
          return InteractiveViewer(
            minScale: .5,
            maxScale: 5,
            boundaryMargin: const EdgeInsets.all(128),
            child: Center(
              child: Hero(
                tag: 'attachment-${widget.event.eventId}',
                child: MimedImage(
                  bytes: file.bytes,
                  name: file.name,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  XFile _xFile(MatrixFile file) => XFile.fromData(
        file.bytes,
        mimeType: file.mimeType,
        name: file.name,
        lastModified: widget.event.originServerTs,
      );

  Future<void> _share(Rect? rect) async {
    setState(() => _saving = true);
    try {
      final file = await _download;
      await SharePlus.instance.share(
        ShareParams(
          files: [_xFile(file)],
          sharePositionOrigin: rect,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final file = await _download;
      final xFile = _xFile(file);
      if (!kIsWeb && Platform.isAndroid) {
        await FileSelector.ensureAndroidInitialized();
        final temporaryDirectory = await getTemporaryDirectory();
        final temporaryPath = '${temporaryDirectory.path}/${file.name}';
        await xFile.saveTo(temporaryPath);
        await MediaStore().saveFile(
          tempFilePath: temporaryPath,
          dirType: DirType.download,
          dirName: DirName.download,
        );
      } else {
        final location = await getSaveLocation(suggestedName: file.name);
        if (location != null) await xFile.saveTo(location.path);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context).download)),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
