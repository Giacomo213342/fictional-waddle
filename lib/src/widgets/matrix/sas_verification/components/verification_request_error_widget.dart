import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../scopes/sas_scope.dart';
import 'sas_verification_bottom_bar.dart';

class VerificationRequestErrorWidget extends StatelessWidget {
  const VerificationRequestErrorWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final verification = SasScope.of(context).verification;
    String message;
    // TODO: handle request.cancelCode and request.cancelReason
    switch (verification.canceledCode) {
      case 'm.user':
        message = AppLocalizations.of(context).keyVerificationErrorUser;
        break;
      default:
        message = AppLocalizations.of(context).keyVerificationErrorGeneric;
        break;
    }
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
                    Icons.cancel,
                    color: Theme.of(context).colorScheme.error,
                    size: 32,
                  ),
                  title: Text(
                    message,
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
