import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../theme/colors/poly_pride.dart';
import '../../../utils/matrix/room_security_level_extension.dart';
import '../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../widgets/matrix/scopes/room_scope.dart';

class RoomEncryptionIndicator extends StatelessWidget {
  const RoomEncryptionIndicator({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return RoomBuilder(
      builder: (context, snapshot) {
        final room = snapshot.data ?? RoomScope.of(context).room;
        final securityState = room.calcRoomSecurityState();
        if (securityState is RoomSecurityState) {
          return RoomSecurityIcon(
            state: securityState,
          );
        } else {
          return FutureBuilder(
            future: securityState,
            builder: (context, snapshot) {
              if (!room.encrypted) {
                return const RoomSecurityIcon(state: RoomSecurityState.wtf);
              }
              return RoomSecurityIcon(
                state: snapshot.data ?? RoomSecurityState.encrypted,
              );
            },
          );
        }
      },
    );
  }
}

class RoomSecurityIcon extends StatelessWidget {
  const RoomSecurityIcon({super.key, required this.state});

  final RoomSecurityState state;

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case RoomSecurityState.wtf:
        return IconButton(
          icon: const Icon(Icons.question_mark),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateWtf,
        );
      case RoomSecurityState.public:
        return IconButton(
          icon: const Icon(Icons.public),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStatePublic,
        );
      case RoomSecurityState.publicKnock:
        return IconButton(
          icon: const Icon(Icons.public),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStatePublicKnock,
        );
      case RoomSecurityState.open:
        return IconButton(
          icon: const Icon(Icons.lock_open),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateOpen,
        );
      case RoomSecurityState.knock:
        return IconButton(
          icon: const Icon(Icons.lock_open),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateKnock,
        );
      case RoomSecurityState.space:
        return IconButton(
          icon: const Icon(Icons.workspaces),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateSpace,
        );
      case RoomSecurityState.unpublic:
        return IconButton(
          icon: const Icon(Icons.no_encryption),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateUnpublic,
        );
      case RoomSecurityState.encrypted:
        return IconButton(
          icon: const Icon(Icons.lock),
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateEncrypted,
        );
      case RoomSecurityState.verifiedEncrypted:
        return IconButton(
          icon: const Icon(Icons.enhanced_encryption),
          color: PolyColors.cyan,
          onPressed: () {},
          tooltip: AppLocalizations.of(context).roomStateVerifiedEncrypted,
        );
    }
  }
}
