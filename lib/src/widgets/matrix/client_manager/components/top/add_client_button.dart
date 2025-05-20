import 'package:flutter/material.dart';

import '../../../../../../l10n/generated/app_localizations.dart';
import '../../../../../pages/splash_screen/splash_screen.dart';
import '../../../../../router/extensions/go_router_path_extension.dart';
import '../../../../ascii_progress_indicator.dart';
import '../../../../future_callback_builder.dart';
import '../../client_manager.dart';

class AddClientButton extends StatelessWidget {
  const AddClientButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: FutureCallbackBuilder(
        callback: () async {
          final callback = context.pushMultiClient;
          final identifier = await ClientManager.of(context).addLoginClient();
          callback(
            '/client/$identifier${SplashPage.routeName}',
          );
        },
        builder: (context, callback, loading, cancel) => loading
            ? const AsciiProgressIndicator()
            : IconButton(
                tooltip: AppLocalizations.of(context).addAccount,
                onPressed: callback,
                icon: const Icon(Icons.add),
              ),
      ),
    );
  }
}
