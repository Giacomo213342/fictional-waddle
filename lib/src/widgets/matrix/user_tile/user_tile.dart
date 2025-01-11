import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/matrix/matrix_state.dart';
import '../../../utils/matrix_to_extension.dart';
import '../../ascii_progress_indicator.dart';
import '../../polycule_overflow_bar.dart';
import '../../share_origin_builder.dart';
import '../avatar_builder/fullscreen_dialog_avatar.dart';
import '../avatar_builder/mxc_avatar.dart';

class UserTile extends StatefulWidget {
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
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends MatrixState<UserTile> {
  @override
  Widget build(BuildContext context) {
    final name = widget.profile.displayName ?? widget.profile.userId;
    final subtitle =
        widget.profile.displayName != null ? widget.profile.userId : null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          leading: FullScreenAvatar.makeImageButton(
            context: context,
            child: MxcAvatar(
              uri: widget.profile.avatarUrl,
              client: client,
              monogram: name,
              dimension: 48,
            ),
            uri: widget.profile.avatarUrl,
            client: client,
            title: name,
          ),
          isThreeLine: subtitle != null,
          title: Text(name),
          subtitle: subtitle == null ? null : SelectableText(subtitle),
        ),
        PolyculeOverflowBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.loading)
              const AsciiProgressIndicator()
            else ...[
              client.getDirectChatFromUserId(widget.profile.userId) != null
                  ? FilledButton.tonal(
                      onPressed: widget.onDirectChat,
                      child: Text(
                        AppLocalizations.of(context).openDirectChat,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: widget.onDirectChat,
                      child: Text(
                        AppLocalizations.of(context).startDirectChat,
                      ),
                    ),
              if (client.getDirectChatFromUserId(widget.profile.userId) !=
                      null &&
                  widget.onVerification != null)
                ElevatedButton(
                  onPressed: widget.onVerification,
                  child: Text(
                    AppLocalizations.of(context).startVerification,
                  ),
                ),
              ShareOriginBuilder(
                builder: (context, rect) => ElevatedButton(
                  onPressed: () => share(rect),
                  child: Text(
                    MaterialLocalizations.of(context).shareButtonLabel,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: widget.onIgnore,
                child: Text(
                  client.ignoredUsers.contains(widget.profile.userId)
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

  @override
  void didUpdateWidget(covariant UserTile oldWidget) {
    if (oldWidget.profile != widget.profile ||
        oldWidget.action != widget.action ||
        oldWidget.loading != widget.loading) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> share(Rect? sharePositionOrigin) async {
    final link = MatrixIdentifierStringExtensionResults(
      primaryIdentifier: widget.profile.userId,
      action: widget.action,
    ).toMatrixToUrl();
    final uri = Uri.tryParse(link);

    final name = widget.profile.displayName ?? widget.profile.userId;
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
