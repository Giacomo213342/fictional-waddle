import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/file_selector.dart';
import '../../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../../../widgets/matrix/profile_builder.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';
import 'display_name_editor.dart';

class OwnProfilePreview extends StatefulWidget {
  const OwnProfilePreview({super.key});

  @override
  State<OwnProfilePreview> createState() => _OwnProfilePreviewState();
}

class _OwnProfilePreviewState extends State<OwnProfilePreview> {
  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final userId = client.userID!;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Stack(
            fit: StackFit.loose,
            alignment: Alignment.centerRight,
            children: [
              ProfileAvatarBuilder(
                userId: userId,
                dimension: 96,
                canOpenFullscreen: true,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: deleteAvatar,
                    icon: const Icon(Icons.delete_forever),
                    tooltip: AppLocalizations.of(context).redact,
                  ),
                  IconButton(
                    onPressed: editAvatar,
                    icon: const Icon(Icons.edit),
                    tooltip: AppLocalizations.of(context).edit,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          Flexible(
            flex: 1,
            child: ProfileBuilder(
              userId: userId,
              builder: (context, snapshot) {
                return ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 192, minHeight: 96),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const DisplayNameEditor(),
                      TextButton.icon(
                        icon: const Icon(Icons.copy),
                        label: Text(
                          userId,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        onPressed: () =>
                            Clipboard.setData(ClipboardData(text: userId)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> editAvatar() async {
    final client = ClientScope.of(context).client;
    final selector = FileSelector(MessageTypes.Image);
    final openedFiles = await selector.selectFiles(
      context,
      enforceSingle: true,
    );
    if (!openedFiles || !mounted) {
      return;
    }
    final selection = await selector.previewSelection(
      context,
      allowCompress: false,
    );
    if (selection == null || selection.files.isEmpty || !mounted) {
      return;
    }
    final mxFiles = await selector.makeMatrixFiles(
      context,
      client.nativeImplementations,
    );

    await client.setAvatar(mxFiles.single.file);
  }

  Future<void> deleteAvatar() async {
    await ClientScope.of(context).client.setAvatar(null);
  }
}
