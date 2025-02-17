import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/ascii_progress_indicator.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
import '../../widgets/matrix/scopes/client_scope.dart';
import 'account_selector.dart';
import 'components/account_preview_tile.dart';

class AccountSelectorView extends StatelessWidget {
  const AccountSelectorView({super.key, required this.controller});

  final AccountSelectorController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).appName),
      ),
      body: Center(
        child: FutureBuilder<void>(
          future: ClientManager.of(context).store.waiForInitialization,
          builder: (context, snapshot) {
            return SimpleDialog(
              title: Text(AppLocalizations.of(context).selectAccount),
              children: [
                if (!snapshot.hasData)
                  const Center(child: AsciiProgressIndicator())
                else
                  ...ClientManager.of(context).store.activeClients.value.map(
                        (client) => ClientScope(
                          client: client,
                          child: AccountPreviewTile(
                            controller: controller,
                          ),
                        ),
                      ),
              ],
            );
          },
        ),
      ),
    );
  }
}
