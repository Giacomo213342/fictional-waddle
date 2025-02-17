import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import '../../../widgets/matrix/avatar_builder/profile_avatar_builder.dart';
import '../../../widgets/matrix/client_manager/client_store.dart';
import '../../../widgets/matrix/scopes/client_scope.dart';
import '../account_selector.dart';

class AccountPreviewTile extends StatelessWidget {
  const AccountPreviewTile({
    super.key,
    required this.controller,
  });

  final AccountSelectorController controller;

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    return StreamBuilder<LoginState>(
      initialData: client.onLoginStateChanged.value,
      stream: client.onLoginStateChanged.stream,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return ListTile(
            leading: const AsciiProgressIndicator(),
            title: Text(AppLocalizations.of(context).loggingInToClient),
          );
        }
        final userId = client.userID;
        if (userId == null) {
          return SizedBox.fromSize(size: Size.zero);
        }
        return ListTile(
          leading: ProfileAvatarBuilder(
            userId: userId,
            dimension: 32,
          ),
          title: Text(userId),
          onTap: () =>
              controller.selectAccount(client.clientName.clientIdentifier),
        );
      },
    );
  }
}
