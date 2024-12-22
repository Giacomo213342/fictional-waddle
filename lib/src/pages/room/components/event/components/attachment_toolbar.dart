import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:matrix/matrix.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../utils/file_selector.dart';
import '../../../../../utils/matrix/matrix_state.dart';
import '../../../../../widgets/polycule_overflow_bar.dart';
import '../../../../../widgets/share_origin_builder.dart';

class AttachmentToolbar extends StatefulWidget {
  const AttachmentToolbar({
    super.key,
    required this.event,
    required this.child,
  });

  final Widget child;
  final Event event;

  @override
  State<AttachmentToolbar> createState() => _AttachmentToolbarState();
}

class _AttachmentToolbarState extends MatrixState<AttachmentToolbar> {
  final canDownload = true;
  final canSaveAs = !kIsWeb && !Platform.isIOS && !Platform.isAndroid;
  final canShare = !kIsWeb && !Platform.isLinux;

  bool get isPdf => widget.event.attachmentMimetype == 'application/pdf';

  bool get canView =>
      !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

  final separator = Platform.isWindows ? r'\' : r'/';

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final density = Theme.of(context).visualDensity;
    final densityOffset = density.vertical - density.baseSizeAdjustment.dx;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          widget.child,
          PolyculeOverflowBar(
            children: loading
                ? [
                    Builder(
                      builder: (context) {
                        return SizedBox(
                          height: (IconTheme.of(context).size ?? 24) +
                              24 -
                              densityOffset,
                          child: const Center(child: LinearProgressIndicator()),
                        );
                      },
                    ),
                  ]
                : [
                    if (canShare)
                      ShareOriginBuilder(
                        builder: (context, rect) {
                          return IconButton(
                            tooltip: MaterialLocalizations.of(context)
                                .shareButtonLabel,
                            onPressed: () => _share(rect),
                            icon: const Icon(Icons.share),
                          );
                        },
                      ),
                    if (canDownload)
                      ShareOriginBuilder(
                        builder: (context, rect) {
                          return IconButton(
                            tooltip: AppLocalizations.of(context).download,
                            onPressed: () => _download(rect),
                            icon: const Icon(Icons.save_alt),
                          );
                        },
                      ),
                    if (canSaveAs)
                      IconButton(
                        tooltip: AppLocalizations.of(context).saveAs,
                        onPressed: _saveAs,
                        icon: const Icon(Icons.save_as),
                      ),
                    if (canView)
                      IconButton(
                        tooltip: AppLocalizations.of(context).openFile,
                        onPressed: _openExternally,
                        icon: const Icon(Icons.visibility),
                      ),
                  ],
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  XFile _buildXFile(MatrixFile mxFile) {
    final bytes = mxFile.bytes;
    final mimeType = mxFile.mimeType;
    return XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: mxFile.name,
      lastModified: widget.event.originServerTs,
    );
  }

  Future<void> _share(Rect? rect) async {
    setState(() {
      loading = true;
    });

    try {
      final mxFile = await widget.event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(mxFile);

      Share.shareXFiles(
        [xfile],
        sharePositionOrigin: rect,
      );
    } catch (e, s) {
      _handleAttachmentError(e, s);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _download(Rect? rect) async {
    if (kIsWeb) {
      return _share(rect);
    }
    if (Platform.isAndroid) {
      return _downloadAndroid(rect);
    }
    setState(() {
      loading = true;
    });
    try {
      final mxFile = await widget.event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(mxFile);

      final directory = await getDownloadsDirectory();

      // no, I would not expect a downloads directory present on my Arch Linux
      await directory!.create();

      File file = File(directory.path + separator + mxFile.name);

      if (await file.exists()) {
        final txid = client.generateUniqueTransactionId();

        String newName;
        if (mxFile.name.contains(r'.')) {
          final lastDot = mxFile.name.lastIndexOf(r'.');

          newName = mxFile.name.replaceRange(lastDot, lastDot, txid);
        } else {
          newName = mxFile.name + txid;
        }

        file = File(directory.path + separator + newName);
      }

      final path = file.path;

      await xfile.saveTo(path);

      _showFileStoredSnackBar(path);
    } catch (e, s) {
      _handleAttachmentError(e, s);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _downloadAndroid([Rect? rect]) async {
    setState(() {
      loading = true;
    });
    try {
      await FileSelector.ensureAndroidInitialized();

      final mxFile = await widget.event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(mxFile);

      final directory = await getTemporaryDirectory();
      final tmpPath = directory.path + separator + mxFile.name;

      await xfile.saveTo(tmpPath);

      final store = MediaStore();
      final info = await store.saveFile(
        tempFilePath: tmpPath,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      final uri = info?.uri;
      if (info == null || !info.isSuccessful || uri == null) {
        return;
      }
      final path = await store.getFilePathFromUri(uriString: uri.toString());
      if (path == null) {
        return;
      }

      _showFileStoredSnackBar(path);
    } catch (e, s) {
      _handleAttachmentError(e, s);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _saveAs() async {
    setState(() {
      loading = true;
    });
    try {
      final mxFile = await widget.event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(mxFile);

      final location = await getSaveLocation(
        suggestedName: mxFile.name,
      );
      if (location == null) {
        return;
      }
      final path = location.path;

      await xfile.saveTo(path);

      _showFileStoredSnackBar(path);
    } catch (e, s) {
      _handleAttachmentError(e, s);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _openExternally() async {
    if (kIsWeb) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      final mxFile = await widget.event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(mxFile);

      final directory = await getTemporaryDirectory();
      // no, I would not expect a temporary directory present on my Arch Linux
      await directory.create();

      final txid = client.generateUniqueTransactionId();

      String name;
      if (mxFile.name.contains(r'.')) {
        final extension = mxFile.name.split(r'.').last;

        name = txid + r'.' + extension;
      } else {
        name = txid;
      }

      final file = File(directory.path + separator + name);
      final path = file.path;

      await xfile.saveTo(path);

      final uri = Uri.file(path);
      await launchUrl(uri);
    } catch (e, s) {
      _handleAttachmentError(e, s);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _showFileStoredSnackBar(String path) async {
    final name = path.split(separator).last;
    final uri = Uri.file(path);
    final canLaunch = await canLaunchUrl(uri);

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).fileDownloadedTo(name),
        ),
        action: canLaunch
            ? SnackBarAction(
                label: AppLocalizations.of(context).openFile,
                onPressed: () => launchUrl(uri),
              )
            : null,
      ),
    );
  }

  void _handleAttachmentError(Object e, StackTrace s) {
    Logs().w('Error sharing file.', e, s);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).errorDownloadingAttachment,
        ),
      ),
    );
  }
}
