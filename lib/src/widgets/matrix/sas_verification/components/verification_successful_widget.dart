import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import 'sas_verification_bottom_bar.dart';

class VerificationSuccessfulWidget extends StatelessWidget {
  const VerificationSuccessfulWidget({
    super.key,
  });

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
              children: [
                ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    size: 32,
                    color: DefaultTextStyle.of(context).style.color,
                  ),
                  title: Text(
                    AppLocalizations.of(context).verificationSuccessful,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
              ],
            ),
          ),
          SasVerificationBottomBar(
            children: [
              FilledButton.tonal(
                onPressed: Navigator.of(context).pop,
                child: Text(AppLocalizations.of(context).close),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
