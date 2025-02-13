import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../l10n/matrix/polycule_matrix_localizations.dart';
import 'scopes/room_scope.dart';

class RoomDisplayNameText extends StatelessWidget {
  const RoomDisplayNameText({super.key});

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: RoomScope.of(context).room.loadHeroUsers(),
        builder: (context, _) => Text(
          RoomScope.of(context).room.getLocalizedDisplayname(
                AppLocalizations.of(context).matrix,
              ),
          overflow: TextOverflow.ellipsis,
        ),
      );
}
