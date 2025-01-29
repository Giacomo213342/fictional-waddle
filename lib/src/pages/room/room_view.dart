import 'package:flutter/material.dart';

import 'package:url_launcher/link.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/avatar_builder/room_avatar.dart';
import '../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../widgets/matrix/room_scope.dart';
import '../room_details/room_details.dart';
import '../user_page/user_page.dart';
import 'components/room_body.dart';
import 'components/room_encryption_inficator.dart';

class RoomView extends StatelessWidget {
  const RoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(2),
          child: RoomBuilder(
            builder: (context, snapshot) {
              final room = snapshot.data ?? RoomScope.of(context).room;
              return RoomAvatar.fullScreenButton(
                context: context,
                room: room,
                dimension: 64,
              );
            },
          ),
        ),
        title: RoomBuilder(
          builder: (context, snapshot) {
            final room = snapshot.data ?? RoomScope.of(context).room;
            Uri? link;
            if (room.isDirectChat) {
              link = Uri.parse(
                context.clientifyLocation(
                  UserPage.makeRouteName(room.directChatMatrixID),
                ),
              );
            } else {
              link = Uri.parse(
                context.clientifyLocation(
                  RoomDetailsPage.makeRouteName(room.id),
                ),
              );
            }
            final style = DefaultTextStyle.of(context);
            return Link(
              uri: link,
              builder: (context, followLink) {
                return TextButton(
                  onPressed: followLink,
                  child: DefaultTextStyle(
                    style: style.style,
                    overflow: style.overflow,
                    textAlign: style.textAlign,
                    softWrap: style.softWrap,
                    maxLines: style.maxLines,
                    child: Text(
                      room.getLocalizedDisplayname(),
                    ),
                  ),
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: AppLocalizations.of(context).search,
            onPressed: () {},
          ),
          const RoomEncryptionIndicator(),
        ],
      ),
      body: Semantics(
        hint: AppLocalizations.of(context).regionChatContents,
        child: const RoomBody(),
      ),
    );
  }
}
