import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:matrix/matrix.dart';
import 'package:media_kit/media_kit.dart';

import '../../l10n/generated/app_localizations.dart';
import '../widgets/file_preview_dialog/file_preview_dialog.dart';

class FileSelector {
  FileSelector(this.msgType);

  bool compress = false;
  List<XFile>? files;

  final String? msgType;

  List<XTypeGroup> _createTypeTypeGroups(AppLocalizations l10n) {
    final useUTI = kIsWeb ? false : Platform.isIOS || Platform.isMacOS;

    final xTypeGroups = <XTypeGroup>[
      XTypeGroup(
        label: l10n.typeGroupFiles,
        mimeTypes: const [],
        uniformTypeIdentifiers: useUTI ? const ['public.content'] : null,
      ),
    ];

    switch (msgType) {
      case MessageTypes.Image:
        xTypeGroups.insertAll(0, [
          XTypeGroup(
            label: l10n.typeGroupImages,
            mimeTypes: const [
              'image/*',
              // Lottie files : application/json
            ],
            uniformTypeIdentifiers: const ['public.image'],
          ),
        ]);
        break;
      case MessageTypes.Video:
        xTypeGroups.insertAll(0, [
          XTypeGroup(
            label: l10n.typeGroupVideos,
            mimeTypes: const ['video/*'],
            uniformTypeIdentifiers: const ['public.video'],
          ),
        ]);
        break;
      case MessageTypes.Audio:
        xTypeGroups.insertAll(0, [
          XTypeGroup(
            label: l10n.typeGroupAudio,
            mimeTypes: const ['audio/*'],
            uniformTypeIdentifiers: const ['public.audio'],
          ),
        ]);
        break;
    }

    return xTypeGroups;
  }

  Future<bool> selectFiles(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final files = this.files = await openFiles(
      acceptedTypeGroups: _createTypeTypeGroups(l10n),
    );
    return files.isNotEmpty;
  }

  Future<FileSendProperties?> previewSelection(BuildContext context) async {
    final files = this.files;
    if (files == null || files.isEmpty) {
      return null;
    }
    final selection = await showAdaptiveDialog<FileSendProperties>(
      context: context,
      builder: (context) => FilePreviewDialog(
        files: files,
      ),
    );
    if (selection == null) {
      return null;
    }

    compress = selection.compress;
    this.files = selection.files;
    return selection;
  }

  Future<List<MatrixFileTuple>> makeMatrixFiles(
    BuildContext context,
    NativeImplementations nativeImplementations,
  ) async {
    final files = this.files;

    if (files == null || files.isEmpty) {
      return [];
    }

    List<MatrixFileTuple> matrixFiles = [];

    for (var file in files) {
      String? mimeType = file.mimeType;
      // the SDK keeps thinking webm files are audio
      if (mimeType == null && file.name.endsWith('.webm')) {
        mimeType = 'video/webm';
      }
      MatrixFile matrixFile = MatrixFile.fromMimeType(
        bytes: await file.readAsBytes(),
        name: file.name,
        mimeType: mimeType,
      );
      if (matrixFile is MatrixImageFile) {
        if (compress) {
          matrixFile = await MatrixImageFile.shrink(
            bytes: matrixFile.bytes,
            name: matrixFile.name,
            maxDimension: 2160,
            mimeType: matrixFile.mimeType,
            nativeImplementations: nativeImplementations,
          );
        }

        final tuple = MatrixFileTuple(
          file: matrixFile,
          // the thumbnail is generated in the SDK
        );
        matrixFiles.add(tuple);
      } else if (matrixFile is MatrixAudioFile) {
        matrixFiles.add(MatrixFileTuple(file: matrixFile));
      } else if (matrixFile is MatrixVideoFile) {
        MatrixImageFile? thumbnail;
        try {
          final player = Player();
          final playable = await Media.memory(matrixFile.bytes);
          player.open(playable);
          const mime = 'image/png';
          final thumbnailData = await player.screenshot(format: mime);
          if (thumbnailData != null) {
            thumbnail = await MatrixImageFile.shrink(
              bytes: thumbnailData,
              name: 'thumbnail.png',
              mimeType: mime,
              nativeImplementations: nativeImplementations,
            );
          }
        } catch (e, s) {
          Logs().d('Error creating video thumbnail', e, s);
        }
        matrixFiles.add(
          MatrixFileTuple(
            file: matrixFile,
            thumbnail: thumbnail,
          ),
        );
      } else {
        matrixFiles.add(MatrixFileTuple(file: matrixFile));
      }
    }

    return matrixFiles;
  }
}

class MatrixFileTuple {
  const MatrixFileTuple({required this.file, this.thumbnail});

  final MatrixFile file;
  final MatrixImageFile? thumbnail;
}
