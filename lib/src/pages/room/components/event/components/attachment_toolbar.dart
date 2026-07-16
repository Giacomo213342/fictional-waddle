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
import '../../../../../widgets/matrix/scopes/client_scope.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/matrix/scopes/matrix_scope.dart';
import '../../../../../widgets/polycule_overflow_bar.dart';
import '../../../../../widgets/share_origin_builder.dart';
import '../m_room_message/m_image.dart';

class AttachmentToolbar extends StatefulWidget {
  const AttachmentToolbar({
    super.key,
    required this.child,
    this.showToolbar = true,
    this.openFullscreen = false,
  });

  final Widget child;
  final bool showToolbar;
  final bool openFullscreen;

  @override
  State<AttachmentToolbar> createState() => _AttachmentToolbarState();
}

class _AttachmentToolbarState extends State<AttachmentToolbar> {
  final canDownload = true;
  final canSaveAs = !kIsWeb && !Platform.isIOS && !Platform.isAndroid;
  final canShare = !kIsWeb && !Platform.isLinux;

  bool isPdf(Event event) => event.attachmentMimetype == 'application/pdf';

  bool get canView =>
      !kIsWeb && (Platform.isLinux || Platform.isMacOS || Platform.isWindows);

  final separator = Platform.isWindows ? r'\' : r'/';

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final event = EventScope.of(context).event;
    final child = widget.openFullscreen
        ? InkWell(
            onTap: () => _openFullscreen(event),
            child: widget.child,
          )
        : widget.child;
    if (!widget.showToolbar) {
      return Center(child: child);
    }
    final density = Theme.of(context).visualDensity;
    final densityOffset = density.vertical - density.baseSizeAdjustment.dx;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          child,
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
                            onPressed: () => _share(event, rect),
                            icon: const Icon(Icons.share),
                          );
                        },
                      ),
                    if (canDownload)
                      ShareOriginBuilder(
                        builder: (context, rect) {
                          return IconButton(
                            tooltip: AppLocalizations.of(context).download,
                            onPressed: () => _download(event, rect),
                            icon: const Icon(Icons.save_alt),
                          );
                        },
                      ),
                    if (canSaveAs)
                      IconButton(
                        tooltip: AppLocalizations.of(context).saveAs,
                        onPressed: () => _saveAs(event),
                        icon: const Icon(Icons.save_as),
                      ),
                    if (canView)
                      IconButton(
                        tooltip: AppLocalizations.of(context).openFile,
                        onPressed: () => _openExternally(event),
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

  Future<void> _openFullscreen(Event event) async {
    final scope = MatrixScope.captureAll(context);
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MatrixScope(
          scope: scope,
          child: _FullscreenAttachment(
            title: event.body,
            onShare: (rect) => _share(event, rect),
            onDownload: (rect) => _download(event, rect),
          ),
        ),
      ),
    );
  }

  XFile _buildXFile(Event event, MatrixFile mxFile) {
    final bytes = mxFile.bytes;
    final mimeType = mxFile.mimeType;
    return XFile.fromData(
      bytes,
      mimeType: mimeType,
      name: mxFile.name,
      lastModified: event.originServerTs,
    );
  }

  Future<void> _share(Event event, Rect? rect) async {
    setState(() {
      loading = true;
    });

    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(event, mxFile);

      await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          sharePositionOrigin: rect,
        ),
      );
    } catch (e, s) {
      _handleAttachmentError(e, s);
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _download(Event event, Rect? rect) async {
    final client = ClientScope.of(context).client;
    if (kIsWeb) {
      return _share(event, rect);
    }
    if (Platform.isAndroid) {
      return _downloadAndroid(event, rect);
    }
    setState(() {
      loading = true;
    });
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(event, mxFile);

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

  Future<void> _downloadAndroid(Event event, [Rect? rect]) async {
    setState(() {
      loading = true;
    });
    try {
      await FileSelector.ensureAndroidInitialized();

      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(event, mxFile);

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

  Future<void> _saveAs(Event event) async {
    setState(() {
      loading = true;
    });
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(event, mxFile);

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

  Future<void> _openExternally(Event event) async {
    if (kIsWeb) {
      return;
    }
    final client = ClientScope.of(context).client;
    setState(() {
      loading = true;
    });
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = _buildXFile(event, mxFile);

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

class _FullscreenAttachment extends StatefulWidget {
  const _FullscreenAttachment({
    required this.title,
    required this.onShare,
    required this.onDownload,
  });

  final String title;
  final Future<void> Function(Rect? rect) onShare;
  final Future<void> Function(Rect? rect) onDownload;

  @override
  State<_FullscreenAttachment> createState() => _FullscreenAttachmentState();
}

class _FullscreenAttachmentState extends State<_FullscreenAttachment> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black54,
        actions: _loading
            ? const [
                Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ]
            : [
                ShareOriginBuilder(
                  builder: (context, rect) => IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).shareButtonLabel,
                    onPressed: () => _run(() => widget.onShare(rect)),
                    icon: const Icon(Icons.share),
                  ),
                ),
                ShareOriginBuilder(
                  builder: (context, rect) => IconButton(
                    tooltip: AppLocalizations.of(context).download,
                    onPressed: () => _run(() => widget.onDownload(rect)),
                    icon: const Icon(Icons.save_alt),
                  ),
                ),
              ],
      ),
      body: InteractiveViewer(
        boundaryMargin: const EdgeInsets.all(128),
        minScale: 0.5,
        maxScale: 5,
        trackpadScrollCausesScale: true,
        child: const ImageMessage(fullscreen: true),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
