import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';

class DefaultRuleTile extends StatelessWidget {
  const DefaultRuleTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.info),
      title: Text(AppLocalizations.of(context).defaultPushRule),
    );
  }
}
