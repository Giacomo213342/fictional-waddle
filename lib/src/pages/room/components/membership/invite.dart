import 'dart:math';

import 'package:flutter/material.dart';

import 'package:matrix/matrix.dart';

import '../../../../../l10n/generated/app_localizations.dart';
import '../../../../widgets/ascii_progress_indicator.dart';
import '../../../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../../../widgets/polycule_overflow_bar.dart';
import '../../room.dart';

class MembershipInviteTile extends StatelessWidget {
  const MembershipInviteTile({
    super.key,
    required this.controller,
    required this.room,
  });

  final RoomController controller;
  final Room room;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 512),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary),
          ),
          child: RoomBuilder(
            room: room,
            builder: (context, snapshot) {
              final room = snapshot.data ?? this.room;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isRowMode = constraints.maxWidth > 500;
                  final avatar = Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RoomAvatar(
                      room: room,
                      dimension: 96,
                    ),
                  );

                  final primary = Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isRowMode) avatar,
                      Text(
                        AppLocalizations.of(context).pendingInvite,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      ListTile(
                        title: Text(
                          room.isDirectChat
                              ? AppLocalizations.of(context)
                                  .inviteLongDM(room.getLocalizedDisplayname())
                              : AppLocalizations.of(context).inviteLongRoom(
                                  room.getLocalizedDisplayname(),
                                ),
                        ),
                      ),
                      if (!room.isDirectChat && room.topic.trim().isNotEmpty)
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: Text(room.topic.trim()),
                        ),
                      if (!room.isDirectChat)
                        ListTile(
                          leading: const Icon(Icons.people),
                          title: Text(
                            AppLocalizations.of(context).roomParticipants(
                              room.getParticipants().length,
                            ),
                          ),
                        ),
                      PolyculeOverflowBar(
                        alignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          if (controller.loading)
                            const AsciiProgressIndicator()
                          else
                            switch (room.joinRules) {
                              JoinRules.public ||
                              JoinRules.invite =>
                                ElevatedButton(
                                  onPressed: controller.joinRoom,
                                  child: Text(
                                    AppLocalizations.of(context).joinRoom,
                                  ),
                                ),
                              JoinRules.knock => ElevatedButton(
                                  onPressed: controller.knockRoom,
                                  child: Text(
                                    AppLocalizations.of(context).knockRoom,
                                  ),
                                ),
                              _ => ElevatedButton(
                                  onPressed: null,
                                  child: Text(
                                    AppLocalizations.of(context)
                                        .youCannotJoinThisRoom,
                                  ),
                                ),
                            },
                        ],
                      ),
                    ],
                  );

                  return !isRowMode
                      ? primary
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            avatar,
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth:
                                    min(constraints.maxWidth - 96 - 16, 398),
                              ),
                              child: primary,
                            ),
                          ],
                        );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
