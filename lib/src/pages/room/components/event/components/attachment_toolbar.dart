import 'dart:io';
import 'dart:math' as math;

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
import '../../../../../widgets/matrix/scopes/event_navigation_scope.dart';
import '../../../../../widgets/matrix/scopes/event_scope.dart';
import '../../../../../widgets/matrix/scopes/matrix_scope.dart';
import '../../../../../widgets/polycule_overflow_bar.dart';
import '../../../../../widgets/share_origin_builder.dart';
import '../m_room_message/m_image.dart';
import '../m_room_message/m_video.dart';

class AttachmentActions {
  const AttachmentActions._();

  static final _separator = Platform.isWindows ? r'\' : r'/';

  static bool get canShare => !kIsWeb && !Platform.isLinux;

  static bool get canDownload => true;

  static XFile buildXFile(Event event, MatrixFile mxFile) {
    return XFile.fromData(
      mxFile.bytes,
      mimeType: mxFile.mimeType,
      name: mxFile.name,
      lastModified: event.originServerTs,
    );
  }

  static Future<void> share(
    BuildContext context,
    Event event, {
    Rect? shareOrigin,
    ValueChanged<bool>? onLoading,
  }) async {
    onLoading?.call(true);
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = buildXFile(event, mxFile);
      await SharePlus.instance.share(
        ShareParams(
          files: [xfile],
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (error, stackTrace) {
      handleError(context, error, stackTrace);
    } finally {
      onLoading?.call(false);
    }
  }

  static Future<void> download(
    BuildContext context,
    Event event, {
    Rect? shareOrigin,
    ValueChanged<bool>? onLoading,
  }) async {
    if (kIsWeb) {
      return share(
        context,
        event,
        shareOrigin: shareOrigin,
        onLoading: onLoading,
      );
    }
    if (Platform.isAndroid) {
      return _downloadAndroid(context, event, onLoading: onLoading);
    }

    final client = ClientScope.of(context).client;
    onLoading?.call(true);
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = buildXFile(event, mxFile);
      final directory = await getDownloadsDirectory();
      await directory!.create();

      var file = File('${directory.path}$_separator${mxFile.name}');
      if (await file.exists()) {
        final txid = client.generateUniqueTransactionId();
        final name = mxFile.name.contains('.')
            ? mxFile.name.replaceRange(
                mxFile.name.lastIndexOf('.'),
                mxFile.name.lastIndexOf('.'),
                txid,
              )
            : '${mxFile.name}$txid';
        file = File('${directory.path}$_separator$name');
      }
      await xfile.saveTo(file.path);
      await showFileStored(context, file.path);
    } catch (error, stackTrace) {
      handleError(context, error, stackTrace);
    } finally {
      onLoading?.call(false);
    }
  }

  static Future<void> _downloadAndroid(
    BuildContext context,
    Event event, {
    ValueChanged<bool>? onLoading,
  }) async {
    onLoading?.call(true);
    try {
      await FileSelector.ensureAndroidInitialized();
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = buildXFile(event, mxFile);
      final directory = await getTemporaryDirectory();
      final tmpPath = '${directory.path}$_separator${mxFile.name}';
      await xfile.saveTo(tmpPath);

      final mediaStore = MediaStore();
      final info = await mediaStore.saveFile(
        tempFilePath: tmpPath,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      final uri = info?.uri;
      if (info == null || !info.isSuccessful || uri == null) return;
      final path = await mediaStore.getFilePathFromUri(
        uriString: uri.toString(),
      );
      if (path != null) await showFileStored(context, path);
    } catch (error, stackTrace) {
      handleError(context, error, stackTrace);
    } finally {
      onLoading?.call(false);
    }
  }

  static Future<void> showFileStored(BuildContext context, String path) async {
    final name = path.split(_separator).last;
    final uri = Uri.file(path);
    final canLaunch = await canLaunchUrl(uri);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context).fileDownloadedTo(name)),
        action: canLaunch
            ? SnackBarAction(
                label: AppLocalizations.of(context).openFile,
                onPressed: () => launchUrl(uri),
              )
            : null,
      ),
    );
  }

  static void handleError(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    Logs().w('Error handling attachment.', error, stackTrace);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).errorDownloadingAttachment,
        ),
      ),
    );
  }
}

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

bool isFullscreenGalleryEvent(Event event) =>
    !event.redacted &&
    {
      MessageTypes.Image,
      MessageTypes.Video,
    }.contains(event.messageType);

class _AttachmentToolbarState extends State<AttachmentToolbar> {
  final canSaveAs = !kIsWeb && !Platform.isIOS && !Platform.isAndroid;

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
                    if (AttachmentActions.canShare)
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
                    if (AttachmentActions.canDownload)
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
    final navigateToEvent = EventNavigationScope.of(context).navigate;
    final mediaEvents = scope.timeline?.timeline.events
            .where(isFullscreenGalleryEvent)
            .toList(growable: false) ??
        [event];
    final initialIndex = mediaEvents.indexWhere(
      (candidate) => candidate.eventId == event.eventId,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => MatrixScope(
          scope: scope,
          child: _FullscreenAttachment(
            events: initialIndex < 0 ? [event] : mediaEvents,
            initialIndex: initialIndex < 0 ? 0 : initialIndex,
            onShare: _share,
            onDownload: _download,
            onNavigateToEvent: navigateToEvent,
          ),
        ),
      ),
    );
  }

  void _setLoading(bool value) {
    if (mounted) setState(() => loading = value);
  }

  Future<void> _share(Event event, Rect? rect) => AttachmentActions.share(
        context,
        event,
        shareOrigin: rect,
        onLoading: _setLoading,
      );

  Future<void> _download(Event event, Rect? rect) => AttachmentActions.download(
        context,
        event,
        shareOrigin: rect,
        onLoading: _setLoading,
      );

  Future<void> _saveAs(Event event) async {
    _setLoading(true);
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = AttachmentActions.buildXFile(event, mxFile);

      final location = await getSaveLocation(
        suggestedName: mxFile.name,
      );
      if (location == null) {
        return;
      }
      final path = location.path;

      await xfile.saveTo(path);

      AttachmentActions.showFileStored(context, path);
    } catch (e, s) {
      AttachmentActions.handleError(context, e, s);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _openExternally(Event event) async {
    if (kIsWeb) {
      return;
    }
    final client = ClientScope.of(context).client;
    _setLoading(true);
    try {
      final mxFile = await event.downloadAndDecryptAttachment();
      final xfile = AttachmentActions.buildXFile(event, mxFile);

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
      AttachmentActions.handleError(context, e, s);
    } finally {
      _setLoading(false);
    }
  }
}

class _FullscreenAttachment extends StatefulWidget {
  const _FullscreenAttachment({
    required this.events,
    required this.initialIndex,
    required this.onShare,
    required this.onDownload,
    required this.onNavigateToEvent,
  });

  final List<Event> events;
  final int initialIndex;
  final Future<void> Function(Event event, Rect? rect) onShare;
  final Future<void> Function(Event event, Rect? rect) onDownload;
  final Future<void> Function(String eventId) onNavigateToEvent;

  @override
  State<_FullscreenAttachment> createState() => _FullscreenAttachmentState();
}

class _FullscreenAttachmentState extends State<_FullscreenAttachment> {
  late final PageController _pageController = PageController(
    initialPage: widget.initialIndex,
  );
  late Event _event = widget.events[widget.initialIndex];
  bool _loading = false;
  bool _imageZoomed = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(_event.body),
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
                IconButton(
                  tooltip: 'Show in timeline',
                  onPressed: _showInTimeline,
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                ),
                ShareOriginBuilder(
                  builder: (context, rect) => IconButton(
                    tooltip: MaterialLocalizations.of(
                      context,
                    ).shareButtonLabel,
                    onPressed: () => _run(() => widget.onShare(_event, rect)),
                    icon: const Icon(Icons.share),
                  ),
                ),
                ShareOriginBuilder(
                  builder: (context, rect) => IconButton(
                    tooltip: AppLocalizations.of(context).download,
                    onPressed: () =>
                        _run(() => widget.onDownload(_event, rect)),
                    icon: const Icon(Icons.save_alt),
                  ),
                ),
              ],
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: _imageZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        itemCount: widget.events.length,
        onPageChanged: (index) {
          setState(() {
            _event = widget.events[index];
            _imageZoomed = false;
          });
        },
        itemBuilder: (context, index) {
          final event = widget.events[index];
          return EventScope(
            event: event,
            child: event.messageType == MessageTypes.Video
                ? SafeArea(
                    top: false,
                    child: VideoMessage(
                      fullscreen: true,
                      active: event.eventId == _event.eventId,
                    ),
                  )
                : _FullscreenImage(
                    onZoomChanged: (zoomed) {
                      if (event.eventId == _event.eventId &&
                          zoomed != _imageZoomed) {
                        setState(() => _imageZoomed = zoomed);
                      }
                    },
                  ),
          );
        },
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

  Future<void> _showInTimeline() async {
    final eventId = _event.eventId;
    await Navigator.of(context).maybePop();
    await WidgetsBinding.instance.endOfFrame;
    await widget.onNavigateToEvent(eventId);
  }
}

class _FullscreenImage extends StatefulWidget {
  const _FullscreenImage({required this.onZoomChanged});

  final ValueChanged<bool> onZoomChanged;

  @override
  State<_FullscreenImage> createState() => _FullscreenImageState();
}

class _FullscreenImageState extends State<_FullscreenImage> {
  final _transformationController = TransformationController();
  final Set<int> _activePointers = {};
  double _dismissOffset = 0;
  bool _zoomed = false;

  double get _scale => _transformationController.value.getMaxScaleOnAxis();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.biggest;
        final imageSize = _fittedImageSize(
          viewport,
          EventScope.of(context).event,
        );
        final opacity = (1 - (_dismissOffset / viewport.height))
            .clamp(0.55, 1.0)
            .toDouble();
        return Listener(
          onPointerDown: _handlePointerDown,
          onPointerMove: _handlePointerMove,
          onPointerUp: _handlePointerEnd,
          onPointerCancel: _handlePointerEnd,
          child: ColoredBox(
            color: Colors.black,
            child: Opacity(
              opacity: opacity,
              child: Transform.translate(
                offset: Offset(0, _dismissOffset),
                child: SizedBox.expand(
                  child: FittedImageInteractiveViewer(
                    transformationController: _transformationController,
                    panEnabled: _zoomed,
                    onInteractionUpdate: (_) =>
                        _constrainToImage(viewport, imageSize),
                    onInteractionEnd: (_) =>
                        _finishInteraction(viewport, imageSize),
                    child: Center(
                      child: SizedBox.fromSize(
                        size: imageSize,
                        child: const ImageMessage(fullscreen: true),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Size _fittedImageSize(Size viewport, Event event) {
    final info = event.infoMap as Map<String, Object?>?;
    final width = (info?['w'] as num?)?.toDouble();
    final height = (info?['h'] as num?)?.toDouble();
    if (width == null || height == null || width <= 0 || height <= 0) {
      return viewport;
    }
    final scale = math.min(viewport.width / width, viewport.height / height);
    return Size(width * scale, height * scale);
  }

  void _handlePointerDown(PointerDownEvent event) {
    _activePointers.add(event.pointer);
    if (_activePointers.length > 1 && _dismissOffset != 0) {
      setState(() => _dismissOffset = 0);
    }
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_scale > 1.01 || _activePointers.length != 1) return;
    final nextOffset = math.max(0.0, _dismissOffset + event.delta.dy);
    if (nextOffset != _dismissOffset) {
      setState(() => _dismissOffset = nextOffset);
    }
  }

  void _handlePointerEnd(PointerEvent event) {
    _activePointers.remove(event.pointer);
    if (_activePointers.isNotEmpty || _scale > 1.01) return;
    if (_dismissOffset >= 96) {
      Navigator.of(context).maybePop();
    } else if (_dismissOffset != 0) {
      setState(() => _dismissOffset = 0);
    }
  }

  void _constrainToImage(Size viewport, Size image) {
    _updateZoomState();
    final matrix = _transformationController.value;
    final translation = matrix.getTranslation();
    final constrained = constrainFittedImageTransform(matrix, viewport, image);
    final constrainedTranslation = constrained.getTranslation();
    if (constrainedTranslation.x == translation.x &&
        constrainedTranslation.y == translation.y) {
      return;
    }
    _transformationController.value = constrained;
  }

  void _finishInteraction(Size viewport, Size image) {
    if (_scale <= 1.01) {
      _transformationController.value = Matrix4.identity();
      _setZoomed(false);
      return;
    }
    _constrainToImage(viewport, image);
  }

  void _updateZoomState() => _setZoomed(_scale > 1.01);

  void _setZoomed(bool value) {
    if (_zoomed == value) {
      return;
    }
    setState(() => _zoomed = value);
    widget.onZoomChanged(value);
  }
}

Matrix4 constrainFittedImageTransform(
  Matrix4 matrix,
  Size viewport,
  Size image,
) {
  final scale = matrix.getMaxScaleOnAxis();
  final translation = matrix.getTranslation();

  double constrainAxis(
    double current,
    double viewportExtent,
    double imageExtent,
  ) {
    if (scale <= 1.01) return 0;
    final margin = (viewportExtent - imageExtent) / 2;
    final firstEdge = -margin * scale;
    final secondEdge = viewportExtent - (margin + imageExtent) * scale;
    final minimum = math.min(firstEdge, secondEdge);
    final maximum = math.max(firstEdge, secondEdge);
    return current.clamp(minimum, maximum).toDouble();
  }

  final dx = constrainAxis(translation.x, viewport.width, image.width);
  final dy = constrainAxis(translation.y, viewport.height, image.height);
  return matrix.clone()..setTranslationRaw(dx, dy, translation.z);
}

/// The zoom surface used by fullscreen message attachments.
///
/// The child already fills the viewport and centers the fitted image. Leaving
/// [InteractiveViewer.alignment] unset is essential: its gesture recognizer
/// and [TransformationController.toScene] both calculate the pinch focal point
/// using a top-left matrix origin.
class FittedImageInteractiveViewer extends StatelessWidget {
  const FittedImageInteractiveViewer({
    super.key,
    required this.transformationController,
    required this.onInteractionUpdate,
    required this.onInteractionEnd,
    required this.child,
    this.panEnabled = true,
  });

  final TransformationController transformationController;
  final GestureScaleUpdateCallback onInteractionUpdate;
  final GestureScaleEndCallback onInteractionEnd;
  final Widget child;
  final bool panEnabled;

  @override
  Widget build(BuildContext context) => InteractiveViewer(
        transformationController: transformationController,
        boundaryMargin: EdgeInsets.zero,
        minScale: 1,
        maxScale: 5,
        panEnabled: panEnabled,
        scaleEnabled: true,
        trackpadScrollCausesScale: true,
        onInteractionUpdate: onInteractionUpdate,
        onInteractionEnd: onInteractionEnd,
        child: child,
      );
}
