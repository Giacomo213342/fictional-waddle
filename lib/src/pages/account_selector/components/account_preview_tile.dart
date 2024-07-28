import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../widgets/ascii_progress_indicator.dart';
import '../../../widgets/matrix/avatar_builder/mxc_avatar.dart';
import '../../../widgets/matrix/client_manager/client_manager.dart';
import '../account_selector.dart';

class AccountPreviewTile extends StatelessWidget {
  const AccountPreviewTile({
    super.key,
    required this.client,
    required this.controller,
  });

  final Client client;
  final AccountSelectorController controller;

  @override
  Widget build(BuildContext context) {
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
        if (snapshot.data != LoginState.loggedIn) {
          return SizedBox.fromSize(size: Size.zero);
        }
        final userId = client.userID!;
        return ListTile(
          leading: FutureBuilder(
            future: client.getAvatarUrl(userId),
            builder: (context, snapshot) => MxcAvatar(
              uri: snapshot.data,
              client: client,
              monogram: userId,
              dimension: 32,
            ),
          ),
          title: Text(userId),
          onTap: () =>
              controller.selectAccount(client.clientName.clientIdentifier),
        );
      },
    );
  }
}
