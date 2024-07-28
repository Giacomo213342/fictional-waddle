import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../widgets/matrix/client_manager/client_manager.dart';
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
        child: SimpleDialog(
          title: Text(AppLocalizations.of(context).selectAccount),
          children: [
            ...ClientManager.activeClients.map(
              (client) => AccountPreviewTile(
                client: client,
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
