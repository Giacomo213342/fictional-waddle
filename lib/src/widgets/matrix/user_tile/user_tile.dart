import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/matrix_to_extension.dart';
import '../../ascii_progress_indicator.dart';
import '../../polycule_overflow_bar.dart';
import '../../share_origin_builder.dart';
import '../avatar_builder/fullscreen_dialog_avatar.dart';
import '../avatar_builder/mxc_avatar.dart';
import '../client_scope.dart';

class UserTile extends StatelessWidget {
  const UserTile({
    super.key,
    required this.profile,
    this.onDirectChat,
    this.onIgnore,
    this.onVerification,
    this.action,
    this.loading = false,
  });

  final Profile profile;
  final VoidCallback? onDirectChat;
  final VoidCallback? onIgnore;
  final VoidCallback? onVerification;
  final bool loading;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final client = ClientScope.of(context).client;
    final name = profile.displayName ?? profile.userId;
    final subtitle = profile.displayName != null ? profile.userId : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          leading: FullScreenAvatar.makeImageButton(
            context: context,
            child: MxcAvatar(
              uri: profile.avatarUrl,
              monogram: name,
              dimension: 48,
            ),
            uri: profile.avatarUrl,
            title: name,
          ),
          isThreeLine: subtitle != null,
          title: Text(name),
          subtitle: subtitle == null ? null : SelectableText(subtitle),
        ),
        PolyculeOverflowBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (loading)
              const AsciiProgressIndicator()
            else ...[
              client.getDirectChatFromUserId(profile.userId) != null
                  ? FilledButton.tonal(
                      onPressed: onDirectChat,
                      child: Text(
                        AppLocalizations.of(context).openDirectChat,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: onDirectChat,
                      child: Text(
                        AppLocalizations.of(context).startDirectChat,
                      ),
                    ),
              if (client.getDirectChatFromUserId(profile.userId) != null &&
                  onVerification != null)
                ElevatedButton(
                  onPressed: onVerification,
                  child: Text(
                    AppLocalizations.of(context).startVerification,
                  ),
                ),
              ShareOriginBuilder(
                builder: (context, rect) => ElevatedButton(
                  onPressed: () => share(context, rect),
                  child: Text(
                    MaterialLocalizations.of(context).shareButtonLabel,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: onIgnore,
                child: Text(
                  client.ignoredUsers.contains(profile.userId)
                      ? AppLocalizations.of(context).unignoreUser
                      : AppLocalizations.of(context).ignoreUser,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> share(BuildContext context, [Rect? sharePositionOrigin]) async {
    final link = MatrixIdentifierStringExtensionResults(
      primaryIdentifier: profile.userId,
      action: action,
    ).toMatrixToUrl();
    final uri = Uri.tryParse(link);

    final name = profile.displayName ?? profile.userId;
    final subject = AppLocalizations.of(context).matrixRoomShareSubject(name);

    if (uri == null) {
      return;
    }
    try {
      await Share.shareUri(uri, sharePositionOrigin: sharePositionOrigin);
    } on UnimplementedError {
      await Share.share(
        link,
        subject: subject,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
