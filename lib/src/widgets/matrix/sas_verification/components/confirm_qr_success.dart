import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../../future_callback_builder.dart';
import '../../scopes/sas_scope.dart';
import 'sas_profile.dart';
import 'sas_verification_bottom_bar.dart';

class ConfirmQrSuccess extends StatelessWidget {
  const ConfirmQrSuccess({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SasProfile(),
                ListTile(
                  title: Text(AppLocalizations.of(context).confirmQrScanned),
                ),
              ],
            ),
          ),
          SasVerificationBottomBar(
            children: [
              FutureCallbackBuilder(
                callback: () => verification.cancel('m.user'),
                builder: (context, callback, loading, _) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).reject),
                      ),
              ),
              FutureCallbackBuilder(
                callback: verification.acceptQRScanConfirmation,
                builder: (context, callback, loading, _) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).confirm),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
