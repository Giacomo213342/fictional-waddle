import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../avatar_builder/mxc_avatar.dart';

class PublicRoomTile extends StatelessWidget {
  const PublicRoomTile({
    super.key,
    required this.room,
    this.onJoin,
    this.onKnock,
    this.onPreview,
    required this.client,
    this.action,
  });

  final PublicRoomsChunk room;
  final Client client;
  final VoidCallback? onJoin;
  final VoidCallback? onKnock;
  final VoidCallback? onPreview;
  final String? action;

  @override
  Widget build(BuildContext context) {
    final name = room.name ?? room.canonicalAlias ?? room.roomId;
    final topic = room.topic;
    final joinRule = JoinRules.values.singleWhere(
      (r) => r.text == (room.joinRule ?? 'public'),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ListTile(
          leading: MxcAvatar(
            uri: room.avatarUrl,
            client: client,
            monogram: name,
            dimension: 48,
          ),
          isThreeLine: topic != null,
          title: Text(name),
          subtitle: topic == null ? null : SelectionArea(child: Text(topic)),
        ),
        ButtonBar(
          alignment: MainAxisAlignment.spaceEvenly,
          children: [
            /*if (controller.loading)
              const CircularProgressIndicator()
            else*/
            ...[
              if (joinRule == JoinRules.public)
                action == 'view'
                    ? FilledButton.tonal(
                        onPressed: onPreview,
                        child: Text(
                          AppLocalizations.of(context).previewRoom,
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onPreview,
                        child: Text(
                          AppLocalizations.of(context).previewRoom,
                        ),
                      ),
              switch (joinRule) {
                JoinRules.public || JoinRules.invite => action == 'join'
                    ? FilledButton.tonal(
                        onPressed: onJoin,
                        child: Text(AppLocalizations.of(context).joinRoom),
                      )
                    : ElevatedButton(
                        onPressed: onJoin,
                        child: Text(AppLocalizations.of(context).joinRoom),
                      ),
                JoinRules.knock => action == 'join'
                    ? FilledButton.tonal(
                        onPressed: onKnock,
                        child: Text(AppLocalizations.of(context).knockRoom),
                      )
                    : ElevatedButton(
                        onPressed: onKnock,
                        child: Text(AppLocalizations.of(context).knockRoom),
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
}
