import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../avatar_builder/mxc_avatar.dart';

class IncomingVerificationRequestContentWidget extends StatelessWidget {
  const IncomingVerificationRequestContentWidget({
    super.key,
    this.profile,
    this.client,
  });

  final Profile? profile;
  final Client? client;

  @override
  Widget build(BuildContext context) {
    final profile = this.profile;
    final client = this.client;
    final displayName =
        profile?.displayName ?? profile?.userId.localpart ?? profile?.userId;
    bool isSenderMe = profile?.userId == client?.userID;
    if (profile != null) {
      if (isSenderMe) {
        return Text(
          AppLocalizations.of(context).incomingVerificationRequestMyself,
        );
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          if (client != null)
            MxcAvatar(
              uri: profile.avatarUrl,
              client: client,
              monogram: profile.displayName ?? profile.userId,
              dimension: 64,
            ),
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              AppLocalizations.of(context)
                  .incomingVerificationRequestUser(displayName),
            ),
          ),
        ],
      );
    }
    return Text(AppLocalizations.of(context).incomingVerificationRequestLong);
  }
}
