import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../ascii_progress_indicator.dart';
import '../../../future_callback_builder.dart';
import '../../scopes/sas_scope.dart';
import 'sas/decimal.dart';
import 'sas/emoji.dart';
import 'sas_verification_bottom_bar.dart';

class CompareSasWidget extends StatelessWidget {
  const CompareSasWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    Widget child;
    String headline;
    if (verification.sasTypes.contains('emoji')) {
      headline = AppLocalizations.of(context).compareSasEmojis;
      child = const CompareSasEmoji();
    } else {
      headline = AppLocalizations.of(context).compareSasNumbers;
      child = const CompareSasDecimal();
    }
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                Focus(
                  autofocus: true,
                  child: Text(
                    headline,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 16),
                child,
                const SizedBox(height: 8),
                Text(AppLocalizations.of(context).compareSasExplanation),
              ],
            ),
          ),
          SasVerificationBottomBar(
            children: [
              FutureCallbackBuilder(
                callback: verification.rejectSas,
                builder: (context, callback, loading) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).noMatch),
                      ),
              ),
              FutureCallbackBuilder(
                callback: verification.acceptSas,
                builder: (context, callback, loading) => loading
                    ? const AsciiProgressIndicator()
                    : FilledButton.tonal(
                        onPressed: callback,
                        child: Text(AppLocalizations.of(context).keysMatch),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
