import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:file_selector/file_selector.dart';
import 'package:matrix/matrix.dart';

import '../../l10n/generated/app_localizations.dart';

class FileSelector {
  FileSelector(this.msgType);

  final String? msgType;

  Future<List<XFile>> selectAndPreviewFile(BuildContext context) async {
    final useUTI = !kIsWeb && Platform.isIOS || Platform.isMacOS;

    final xTypeGroups = <XTypeGroup>[
      XTypeGroup(
        label: AppLocalizations.of(context).typeGroupFiles,
        mimeTypes: const [],
        uniformTypeIdentifiers: useUTI ? const ['public.content'] : null,
      ),
    ];

    switch (msgType) {
      case MessageTypes.Image:
        xTypeGroups.insertAll(0, [
          XTypeGroup(
            label: AppLocalizations.of(context).typeGroupImages,
            mimeTypes: const ['image/*', 'application/json'],
            uniformTypeIdentifiers: const ['public.image'],
          ),
        ]);
        break;
      case MessageTypes.Video:
        xTypeGroups.insertAll(0, [
          XTypeGroup(
            label: AppLocalizations.of(context).typeGroupVideos,
            mimeTypes: const ['video/*'],
            uniformTypeIdentifiers: const ['public.video'],
          ),
        ]);
        break;
      case MessageTypes.Audio:
        xTypeGroups.insertAll(0, [
          XTypeGroup(
            label: AppLocalizations.of(context).typeGroupAudio,
            mimeTypes: const ['audio/*'],
            uniformTypeIdentifiers: const ['public.audio'],
          ),
        ]);
        break;
    }

    final List<XFile> files = await openFiles(acceptedTypeGroups: xTypeGroups);
    return files;
  }
}
