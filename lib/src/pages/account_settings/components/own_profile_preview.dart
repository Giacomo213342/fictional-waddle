import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../../../widgets/matrix/profile_builder.dart';

class OwnProfilePreview extends StatelessWidget {
  const OwnProfilePreview({
    super.key,
    required this.client,
    this.onEdit,
    this.onRemove,
  });

  final Client client;
  final VoidCallback? onEdit;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
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
                client: client,
                dimension: 96,
                canOpenFullscreen: true,
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: onRemove,
                    icon: const Icon(Icons.delete_forever),
                    tooltip: AppLocalizations.of(context).redact,
                  ),
                  IconButton(
                    onPressed: onEdit,
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
              client: client,
              builder: (context, snapshot) {
                final displayName =
                    snapshot.data?.displayName ?? userId.localpart ?? userId;
                return ConstrainedBox(
                  constraints:
                      const BoxConstraints(maxHeight: 192, minHeight: 96),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
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
}
