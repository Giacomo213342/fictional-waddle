import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:matrix/matrix.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/file_selector.dart';
import '../../ascii_progress_indicator.dart';
import '../../share_origin_builder.dart';
import '../mxc_uri_image.dart';
import '../retry_download_button.dart';
import 'mxc_avatar.dart';

class FullScreenAvatar extends StatelessWidget {
  const FullScreenAvatar({
    super.key,
    required this.uri,
    required this.client,
    required this.title,
  });

  static Widget makeImageButton({
    required BuildContext context,
    required Widget child,
    Uri? uri,
    required Client client,
    required String title,
  }) {
    if (uri == null) {
      return child;
    }
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => FullScreenAvatar(
            client: client,
            uri: uri,
            title: title,
          ),
          fullscreenDialog: true,
          barrierDismissible: true,
        ),
      ),
      child: child,
    );
  }

  final Uri uri;
  final Client client;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        actions: [
          ShareOriginBuilder(
            builder: (context, rect) {
              return IconButton(
                tooltip: AppLocalizations.of(context).share,
                onPressed: () => _share(rect),
                icon: const Icon(Icons.save_alt),
              );
            },
          ),
        ],
      ),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: InteractiveViewer(
        clipBehavior: Clip.none,
        boundaryMargin: const EdgeInsets.all(128),
        minScale: 0.25,
        maxScale: 4,
        trackpadScrollCausesScale: true,
        constrained: true,
        child: MxcUriImageBuilder(
          uri: uri,
          client: client,
          fit: BoxFit.scaleDown,
          imageBuilder: (context, snapshot, retryCallback) {
            final image = snapshot.data;
            return Stack(
              alignment: Alignment.center,
              fit: StackFit.loose,
              children: [
                AnimatedOpacity(
                  opacity: image == null ? 0 : 1,
                  duration: MxcAvatar.kFadeDuration,
                  curve: Curves.easeInOut,
                  child: image,
                ),
                AnimatedOpacity(
                  opacity: image == null ? 1 : 0,
                  duration: MxcAvatar.kFadeDuration,
                  curve: Curves.easeInOut,
                  child: Center(
                    child: retryCallback == null
                        ? const AsciiProgressIndicator()
                        : RetryDownloadButton(
                            callback: retryCallback,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _share([Rect? rect]) async {
    final uri = await this.uri.getDownloadUri(client);

    final bytes = await client.httpClient.readBytes(
      uri,
      headers: {'authorization': 'Bearer ${client.accessToken}'},
    );
    final mime = lookupMimeType(
      '/dev/null',
      headerBytes: bytes.getRange(0, min(64, bytes.length)).toList(),
    );
    if (mime == null) {
      return;
    }
    final extension = extensionFromMime(mime);
    if (extension == null) {
      return;
    }
    final name = '$title.$extension';

    final file = XFile.fromData(
      bytes,
      mimeType: mime,
      name: name,
    );

    if (kIsWeb || Platform.isIOS) {
      await Share.shareXFiles(
        [file],
        text: title,
        sharePositionOrigin: rect,
      );
      return;
    }

    if (Platform.isAndroid) {
      await FileSelector.ensureAndroidInitialized();

      final directory = await getTemporaryDirectory();
      final tmpPath = '${directory.path}/${file.name}';

      await file.saveTo(tmpPath);

      final store = MediaStore();
      await store.saveFile(
        tempFilePath: tmpPath,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      return;
    }

    final location = await getSaveLocation(
      suggestedName: name,
    );
    if (location == null) {
      return;
    }
    final path = location.path;

    await file.saveTo(path);
  }
}
