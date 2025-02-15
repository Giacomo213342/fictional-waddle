import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';
import 'scopes/room_scope.dart';

class RoomDisplayNameText extends StatelessWidget {
  const RoomDisplayNameText({super.key});

  @override
  Widget build(BuildContext context) {
    final room = RoomScope.of(context).room;
    return FutureBuilder(
      future: room.name.isEmpty && room.canonicalAlias.isEmpty
          // load the hero users if the room name is now known
          ? room.loadHeroUsers()
          : null,
      builder: (context, _) => Text(
        room.getLocalizedDisplayname(AppLocalizations.of(context).matrix),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
