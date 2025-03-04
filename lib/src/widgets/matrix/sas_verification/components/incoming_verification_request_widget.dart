import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../../future_callback_builder.dart';
import '../../profile_builder.dart';
import '../../scopes/client_scope.dart';
import '../../scopes/sas_scope.dart';
import 'sas_profile.dart';
import 'sas_verification_bottom_bar.dart';

class IncomingVerificationRequestWidget extends StatelessWidget {
  const IncomingVerificationRequestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    final mxid = SasScope.of(context).verification.userId;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    Icons.security,
                    size: 32,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  title: Text(
                    AppLocalizations.of(context).incomingVerificationRequest,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: 8),
                if (ClientScope.of(context).client.userID == mxid)
                  Text(
                    AppLocalizations.of(context)
                        .incomingVerificationRequestMyself,
                  )
                else ...[
                  const SasProfile(),
                  ProfileBuilder(
                    userId: mxid,
                    builder: (context, snapshot) {
                      final profile = snapshot.data;
                      if (profile == null) {
                        return Text(
                          AppLocalizations.of(context)
                              .incomingVerificationRequestLong,
                        );
                      }
                      return Text(
                        AppLocalizations.of(context)
                            .incomingVerificationRequestUser(
                          profile.displayName ?? mxid.localpart ?? mxid,
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          SasVerificationBottomBar(
            children: [
              FutureCallbackBuilder(
                callback: verification.rejectVerification,
                builder: (context, callback, loading, _) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).reject),
                      ),
              ),
              FutureCallbackBuilder(
                callback: verification.acceptVerification,
                builder: (context, callback, loading, _) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).proceed),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
