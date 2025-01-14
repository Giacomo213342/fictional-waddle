import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../utils/matrix/matrix_state.dart';
import '../../../utils/matrix_to_extension.dart';
import '../../ascii_progress_indicator.dart';
import '../../polycule_overflow_bar.dart';
import '../../share_origin_builder.dart';
import '../avatar_builder/mxc_avatar.dart';
import '../html/polycule_html_view.dart';

class PublicRoomTile extends StatefulWidget {
  const PublicRoomTile({
    super.key,
    required this.room,
    this.onJoin,
    this.onKnock,
    this.onPreview,
    this.action,
    this.loading = false,
  });

  final PublicRoomsChunk room;
  final VoidCallback? onJoin;
  final VoidCallback? onKnock;
  final VoidCallback? onPreview;
  final bool loading;
  final String? action;

  @override
  State<PublicRoomTile> createState() => _PublicRoomTileState();
}

class _PublicRoomTileState extends MatrixState<PublicRoomTile> {
  @override
  Widget build(BuildContext context) {
    final name =
        widget.room.name ?? widget.room.canonicalAlias ?? widget.room.roomId;
    final topic = widget.room.topic;
    final joinRule = JoinRules.values.singleWhere(
      (r) => r.text == (widget.room.joinRule ?? 'public'),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          leading: MxcAvatar(
            uri: widget.room.avatarUrl,
            client: client,
            monogram: name,
            dimension: 48,
          ),
          isThreeLine: topic != null,
          title: Text(name),
          subtitle: topic == null
              ? null
              : SelectionArea(
                  child: PolyculeHtmlView(
                    html: topic.replaceAll('\n', r'<br />'),
                    globalKeyTag: widget.room.roomId,
                    client: client,
                  ),
                ),
        ),
        PolyculeOverflowBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (widget.loading)
              const AsciiProgressIndicator()
            else ...[
              if (widget.room.canonicalAlias is String)
                ShareOriginBuilder(
                  builder: (context, rect) => ElevatedButton(
                    onPressed: () => share(rect),
                    child: Text(
                      MaterialLocalizations.of(context).shareButtonLabel,
                    ),
                  ),
                ),
              if (joinRule == JoinRules.public)
                widget.action == 'view'
                    ? FilledButton.tonal(
                        onPressed: widget.onPreview,
                        child: Text(
                          AppLocalizations.of(context).previewRoom,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: widget.onPreview,
                        child: Text(
                          AppLocalizations.of(context).previewRoom,
                        ),
                      ),
              switch (joinRule) {
                JoinRules.public || JoinRules.invite => widget.action == 'join'
                    ? FilledButton.tonal(
                        onPressed: widget.onJoin,
                        child: Text(
                          AppLocalizations.of(context).joinRoom,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: widget.onJoin,
                        child: Text(
                          AppLocalizations.of(context).joinRoom,
                        ),
                      ),
                JoinRules.knock => widget.action == 'join'
                    ? FilledButton.tonal(
                        onPressed: widget.onKnock,
                        child: Text(
                          AppLocalizations.of(context).knockRoom,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: widget.onKnock,
                        child: Text(
                          AppLocalizations.of(context).knockRoom,
                        ),
                      ),
                _ => ElevatedButton(
                    onPressed: null,
                    child: Text(
                      AppLocalizations.of(context).youCannotJoinThisRoom,
                    ),
                  ),
              },
            ],
          ],
        ),
      ],
    );
  }

  @override
  void didUpdateWidget(covariant PublicRoomTile oldWidget) {
    if (oldWidget.room != widget.room ||
        oldWidget.action != widget.action ||
        oldWidget.loading != widget.loading) {
      setState(() {});
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> share(Rect? sharePositionOrigin) async {
    final alias = widget.room.canonicalAlias;
    if (alias == null) {
      return;
    }
    final link = MatrixIdentifierStringExtensionResults(
      primaryIdentifier: alias,
      action: widget.action,
    ).toMatrixToUrl();
    final uri = Uri.tryParse(link);

    final room =
        widget.room.name ?? widget.room.canonicalAlias ?? widget.room.roomId;
    final subject = AppLocalizations.of(context).matrixRoomShareSubject(room);

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
