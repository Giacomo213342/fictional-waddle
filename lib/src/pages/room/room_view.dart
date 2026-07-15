import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../router/extensions/go_router_path_extension.dart';
import '../../widgets/matrix/avatar_builder/room_builder.dart';
import '../../widgets/matrix/room_display_name_text.dart';
import '../../widgets/matrix/scopes/room_scope.dart';
import '../room_details/room_details.dart';
import '../room_list/room_list.dart';
import '../user_page/user_page.dart';
import 'components/room_body.dart';
import 'components/room_encryption_inficator.dart';

class RoomView extends StatelessWidget {
  const RoomView({super.key});

  @override
  Widget build(BuildContext context) {
    void leaveRoom() => context.goMultiClient(RoomListPage.routeName);

    return BackButtonListener(
      onBackButtonPressed: () async {
        leaveRoom();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: leaveRoom,
          ),
          title: RoomBuilder(
            builder: (context, snapshot) {
              final room = snapshot.data ?? RoomScope.of(context).room;

              final style = DefaultTextStyle.of(context);
              return TextButton(
                onPressed: () => context.pushMultiClient(
                  room.isDirectChat
                      ? UserPage.makeRoomRouteName(
                          room.id,
                          room.directChatMatrixID!,
                        )
                      : RoomDetailsPage.makeRouteName(room.id),
                ),
                child: DefaultTextStyle(
                  style: style.style,
                  overflow: style.overflow,
                  textAlign: style.textAlign,
                  softWrap: style.softWrap,
                  maxLines: style.maxLines,
                  child: const RoomDisplayNameText(),
                ),
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
      ),
    );
  }
}
