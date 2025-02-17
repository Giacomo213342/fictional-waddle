import 'package:flutter/material.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../pages/splash_screen/splash_screen.dart';
import '../../../../router/extensions/go_router_path_extension.dart';
import '../client_manager.dart';

class AddClientButton extends StatelessWidget {
  const AddClientButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: IconButton(
        tooltip: AppLocalizations.of(context).addAccount,
        onPressed: () {
          final identifier = ClientManager.of(context).addLoginClient();
          context.pushMultiClient(
            '/client/$identifier${SplashPage.routeName}',
          );
        },
        icon: const Icon(Icons.add),
      ),
    );
  }
}
