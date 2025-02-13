import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:matrix/matrix.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/matrix_to_extension.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';
import '../../../widgets/share_origin_builder.dart';

class PublicRoomAddressTile extends StatelessWidget {
  const PublicRoomAddressTile({super.key});

  @override
  Widget build(BuildContext context) {
    final r = RoomScope.of(context).room;
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? r;
        return ListTile(
          title: ShareOriginBuilder(
            builder: (context, rect) => ElevatedButton.icon(
              onPressed: () => sharePublicAddress(context, rect),
              icon: const Icon(Icons.share),
              label: Text(
                room.canonicalAlias,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          trailing: IconButton(
            onPressed: () => Clipboard.setData(
              ClipboardData(text: room.canonicalAlias),
            ),
            icon: const Icon(Icons.copy),
            tooltip: AppLocalizations.of(context).copyRoomAddress,
          ),
        );
      },
    );
  }

  Future<void> sharePublicAddress(BuildContext context, [Rect? rect]) async {
    final room = RoomScope.of(context).room;
    final alias = room.canonicalAlias;
    if (alias.isEmpty) {
      return;
    }
    final link = MatrixIdentifierStringExtensionResults(
      primaryIdentifier: alias,
    ).toMatrixToUrl();
    final uri = Uri.tryParse(link);

    final subject = AppLocalizations.of(context).matrixRoomShareSubject(
      room.getLocalizedDisplayname(),
    );

    if (uri == null) {
      return;
    }
    try {
      await Share.shareUri(uri, sharePositionOrigin: rect);
    } on UnimplementedError {
      await Share.share(
        link,
        subject: subject,
        sharePositionOrigin: rect,
      );
    }
  }
}
