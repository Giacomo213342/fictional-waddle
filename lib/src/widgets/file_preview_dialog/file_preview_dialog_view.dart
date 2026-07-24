import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import 'componets/x_file_preview.dart';
import 'file_preview_dialog.dart';

class FilePreviewDialogView extends StatelessWidget {
  const FilePreviewDialogView({super.key, required this.controller});

  final FilePreviewDialogController controller;

  @override
  Widget build(BuildContext context) {
    final files = controller.files;
    return AlertDialog.adaptive(
      title: Text(
        AppLocalizations.of(context).sendFiles,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 786),
              child: Wrap(
                alignment: WrapAlignment.spaceEvenly,
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.spaceEvenly,
                children: files
                    .map(
                      (file) => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          XFilePreview(
                            file: file,
                            onRemove: () => controller.remove(file),
                          ),
                          if (isImageXFile(file))
                            SizedBox(
                              width: 224,
                              child: TextField(
                                controller:
                                    controller.descriptionControllers[file],
                                maxLines: 3,
                                minLines: 1,
                                decoration: const InputDecoration(
                                  labelText: 'Image description',
                                  hintText:
                                      'Describe the image for accessibility',
                                  prefixIcon: Icon(Icons.description_outlined),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
            FutureBuilder<int>(
              initialData: controller.getLastTotalSize,
              future: controller.getTotalSize(),
              builder: (context, snapshot) {
                final size = snapshot.data;
                return ListTile(
                  title: Text(
                    size == null
                        ? AppLocalizations.of(context).checkingTotalSendSize
                        : AppLocalizations.of(context).totalSendSize(size),
                  ),
                );
              },
            ),
            if (controller.widget.allowCompress)
              SwitchListTile.adaptive(
                title: Text(AppLocalizations.of(context).compressFiles),
                subtitle:
                    Text(AppLocalizations.of(context).compressFilesSubtitle),
                value: controller.compress,
                onChanged: controller.setCompress,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: controller.cancel,
          child: Text(
            AppLocalizations.of(context).cancel,
          ),
        ),
        TextButton(
          onPressed: controller.files.isNotEmpty ? controller.send : null,
          child: Text(
            AppLocalizations.of(context).send,
          ),
        ),
      ],
    );
  }
}
