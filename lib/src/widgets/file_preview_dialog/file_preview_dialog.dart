import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';

import 'file_preview_dialog_view.dart';

class FilePreviewDialog extends StatefulWidget {
  const FilePreviewDialog({
    super.key,
    required this.files,
    this.allowCompress = true,
  });

  final List<XFile> files;
  final bool allowCompress;

  @override
  State<FilePreviewDialog> createState() => FilePreviewDialogController();
}

class FilePreviewDialogController extends State<FilePreviewDialog> {
  final gridDelegate =
      const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 512);

  bool compress = false;
  List<XFile> files = [];
  final Map<XFile, TextEditingController> descriptionControllers = {};

  int? _lastSize;

  int? get getLastTotalSize => _lastSize;

  Future<int> getTotalSize() async {
    int size = 0;
    for (var file in files) {
      size += await file.length();
    }
    _lastSize = size;
    return size;
  }

  @override
  void initState() {
    files = widget.files;
    for (final file in files) {
      descriptionControllers[file] = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in descriptionControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FilePreviewDialogView(controller: this);

  void cancel() => Navigator.of(context).pop();

  void send() {
    if (files.isNotEmpty) {
      return Navigator.of(context).pop(
        FileSendProperties(
          files,
          compress,
          descriptions: {
            for (final file in files)
              if (descriptionControllers[file]!.text.trim().isNotEmpty)
                file: descriptionControllers[file]!.text.trim(),
          },
        ),
      );
    }
    return Navigator.of(context).pop();
  }

  void remove(XFile file) {
    setState(() {
      files.remove(file);
      descriptionControllers.remove(file)?.dispose();
    });
  }

  void setCompress(bool value) => setState(() => compress = value);
}

class FileSendProperties {
  const FileSendProperties(
    this.files,
    this.compress, {
    this.descriptions = const {},
  });

  final List<XFile> files;
  final bool compress;
  final Map<XFile, String> descriptions;
}
