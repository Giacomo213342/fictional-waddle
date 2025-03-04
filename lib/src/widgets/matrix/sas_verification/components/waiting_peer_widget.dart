import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../../future_callback_builder.dart';
import '../../scopes/sas_scope.dart';
import 'sas_profile.dart';
import 'sas_verification_bottom_bar.dart';

class WaitingPeerWidget extends StatelessWidget {
  const WaitingPeerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SasProfile(),
                const AsciiProgressIndicator(),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: Text(
                    AppLocalizations.of(context).waitingForVerification,
                  ),
                ),
              ],
            ),
          ),
          SasVerificationBottomBar(
            children: [
              FutureCallbackBuilder(
                callback: () =>
                    SasScope.of(context).verification.cancel('m.user'),
                builder: (context, callback, loading, _) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).cancel),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
