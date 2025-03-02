import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../future_callback_builder.dart';
import '../../../scopes/sas_scope.dart';

class SasTile extends StatelessWidget {
  const SasTile({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: FutureCallbackBuilder(
            callback: () => SasScope.of(context)
                .verification
                .continueVerification(EventTypes.Sas),
            builder: (context, callback, _) => FilledButton.icon(
              onPressed: callback,
              icon: const Icon(Icons.password),
              label: Text(AppLocalizations.of(context).compareSas),
            ),
          ),
        ),
      );
}
