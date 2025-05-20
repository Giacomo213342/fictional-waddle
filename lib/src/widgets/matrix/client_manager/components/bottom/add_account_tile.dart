import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../pages/splash_screen/splash_screen.dart';
import '../../../../ascii_progress_indicator.dart';
import '../../../../future_callback_builder.dart';
import '../../client_manager.dart';

class AddAccountTile extends StatelessWidget {
  const AddAccountTile({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureCallbackBuilder(
      callback: () async {
        final navigator = Navigator.of(context);
        final identifier = await ClientManager.of(context).addLoginClient();
        navigator.pop('/client/$identifier${SplashPage.routeName}');
      },
      builder: (context, callback, loading, cancel) => ListTile(
        onTap: callback,
        title: Text(AppLocalizations.of(context).addAccount),
        leading:
            loading ? const AsciiProgressIndicator() : const Icon(Icons.add),
      ),
    );
  }
}
