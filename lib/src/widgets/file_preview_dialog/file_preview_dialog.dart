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
    super.initState();
  }

  @override
  Widget build(BuildContext context) => FilePreviewDialogView(controller: this);

  void cancel() => Navigator.of(context).pop();

  void send() {
    if (files.isNotEmpty) {
      return Navigator.of(context).pop(
        FileSendProperties(files, compress),
      );
    }
    return Navigator.of(context).pop();
  }

  void remove(XFile file) {
    setState(() {
      files.remove(file);
    });
  }

  void setCompress(bool value) => setState(() => compress = value);
}

class FileSendProperties {
  const FileSendProperties(this.files, this.compress);

  final List<XFile> files;
  final bool compress;
}
