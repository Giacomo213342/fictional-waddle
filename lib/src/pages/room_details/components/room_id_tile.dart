import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';

class RoomIdTile extends StatelessWidget {
  const RoomIdTile({super.key});

  @override
  Widget build(BuildContext context) {
    final r = RoomScope.of(context).room;
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? r;
        return ListTile(
          title: SelectableText(room.id),
          trailing: IconButton(
            onPressed: () => Clipboard.setData(
              ClipboardData(text: room.id),
            ),
            icon: const Icon(Icons.copy),
            tooltip: MaterialLocalizations.of(context).copyButtonLabel,
          ),
          subtitle: Text(AppLocalizations.of(context).roomId),
        );
      },
    );
  }
}
