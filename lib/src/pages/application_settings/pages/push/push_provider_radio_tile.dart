import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';

class PushProviderRadioTile extends StatelessWidget {
  const PushProviderRadioTile({
    super.key,
    this.distributor,
    this.isSingleProvider = false,
  });

  final String? distributor;
  final bool isSingleProvider;

  @override
  Widget build(BuildContext context) {
    String? label = distributor;
    if (label == null) {
      label = AppLocalizations.of(context).disablePushNotifications;
    } else if (label.startsWith('business.braid.polycule')) {
      label = AppLocalizations.of(context).googleFirebase;
    } else if (isSingleProvider) {
      label = AppLocalizations.of(context).unifiedPush;
    }

    return RadioListTile<String?>.adaptive(
      value: distributor,
      title: Text(label),
    );
  }
}
