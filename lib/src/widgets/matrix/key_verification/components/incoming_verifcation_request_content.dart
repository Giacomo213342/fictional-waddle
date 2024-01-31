import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';

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
          // TODO : show profile pic here
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
