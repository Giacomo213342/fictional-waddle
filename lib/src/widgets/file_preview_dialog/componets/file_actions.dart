import 'package:flutter/material.dart';

import 'package:cross_file/cross_file.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../polycule_text_shadow.dart';

class FileActions extends StatelessWidget {
  const FileActions({
    super.key,
    required this.file,
    required this.child,
    required this.onDelete,
  });

  final XFile file;
  final Widget child;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  size: 128,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: child,
              ),
              Align(
                alignment: Alignment.bottomLeft,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: PolyculeTextShadow(
                    child: Text(
                      file.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topLeft,
                child: FutureBuilder(
                  future: file.length(),
                  builder: (context, snapshot) {
                    final size = snapshot.data;
                    String tooltip = AppLocalizations.of(context).mimeType(
                      file.mimeType ?? file.name.split('.').lastOrNull,
                    );
                    if (size != null) {
                      tooltip +=
                          '\n${AppLocalizations.of(context).fileSize(size)}';
                    }
                    return IconButton(
                      tooltip: tooltip,
                      onPressed: () {},
                      icon: const Icon(Icons.info),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  tooltip:
                      MaterialLocalizations.of(context).deleteButtonTooltip,
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
